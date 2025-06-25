class ZCL_IM__JIRA_UPDATE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_ORDER_SAVE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__JIRA_UPDATE IMPLEMENTATION.


  METHOD if_ex_order_save~change_before_update.
    "on each save we will send values for jira fields.
    DATA lv_jira_guid TYPE crmt_po_number_sold.
    DATA lv_msg TYPE symsg.
    DATA: lo_api_object TYPE REF TO cl_ags_crm_1o_api,
          lt_status     TYPE crmt_status_wrkt,
          ls_status_com TYPE crmt_status_com,
          lv_status_u   TYPE crm_j_status,
          lt_status_com TYPE crmt_status_comt.

    CALL METHOD zcl_z_jira_charm_integration=>get_jira_id
      EXPORTING
        iv_guid    = iv_guid
      IMPORTING
        ev_jira_id = lv_jira_guid.

    IF lv_jira_guid IS NOT INITIAL.
      CALL METHOD zcl_z_jira_charm_integration=>set_jira_fields
        EXPORTING
          iv_guid          = iv_guid
        IMPORTING
          es_error_message = lv_msg.
      "on withdrow we will send status update for jira.
      "Read status from change document
      "Get document instance
      CALL METHOD cl_ags_crm_1o_api=>get_instance
        EXPORTING
          iv_language                   = sy-langu
          iv_header_guid                = iv_guid
          iv_process_mode               = cl_ags_crm_1o_api=>ac_mode-change
        IMPORTING
          eo_instance                   = lo_api_object
        EXCEPTIONS
          invalid_parameter_combination = 1
          error_occurred                = 2
          OTHERS                        = 3.
      IF sy-subrc <> 0.
      ENDIF.

**check status
      lo_api_object->get_status(
        IMPORTING
          ev_user_status       = lv_status_u
          et_status            = lt_status
        EXCEPTIONS
          document_not_found   = 1
          error_occurred       = 2
          document_locked      = 3
          no_change_authority  = 4
          no_display_authority = 5
          no_change_allowed    = 6
          OTHERS               = 7
      ).
      IF sy-subrc <> 0.
      ENDIF.
      IF lv_status_u = 'E0010'. "if we are canceling CD, update will be done in ORDER_SAVE BADI.
        "process status change on Jira side
        TRY.
            CALL METHOD zcl_z_jira_charm_integration=>set_jira_status
              EXPORTING
                iv_guid          = iv_guid
                iv_status        = lv_status_u
              IMPORTING
                es_error_message = DATA(ls_error_message).
          CATCH
            cx_socm_condition_violated
            cx_socm_declared_exception.
* no problem --> reason will be analysed later on
        ENDTRY.
        IF ls_error_message IS NOT INITIAL.
          " show message in webui
          cl_ai_crm_utility=>show_message( ls_error_message ).
          IF ls_error_message-msgv1 EQ 'STA'.
            "status was already set before?
            "or not? additional field with last sucsessful status transfer to check?
            "what to do?
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  method IF_EX_ORDER_SAVE~CHECK_BEFORE_SAVE.
  endmethod.


  method IF_EX_ORDER_SAVE~PREPARE.
  endmethod.
ENDCLASS.
