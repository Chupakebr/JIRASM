class ZCL_IM_JIRA_INT_SOCM_COND definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SOCM_CHECK_CONDITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_JIRA_INT_SOCM_COND IMPLEMENTATION.


  METHOD if_ex_socm_check_condition~check_condition.
    DATA:
      lo_api_object    TYPE REF TO cl_ags_crm_1o_api,
      ls_error_message TYPE symsg.

    BREAK-POINT ID socm.

    conditions_ok = abap_true.

    CALL METHOD zcl_z_jira_charm_integration=>get_jira_id
      EXPORTING
        iv_guid    = hf_instance->change_document_id
      IMPORTING
        ev_jira_id = DATA(lv_jira_id).


* !!! This checks will be processed only for documents with Jira id.
    IF lv_jira_id IS NOT INITIAL." and ls_customer_h-zzjira_guid is not initial.
      CASE flt_val.  "values must be chosen from DB-table TSOCM_CONDITIONS

        WHEN 'ZJIRA_STAT'.

          "Read status from change document
          CALL METHOD cl_hf_helper=>get_estat_of_change_document
            EXPORTING
              im_objnr = hf_instance->change_document_id
            IMPORTING
              ex_estat = DATA(ls_status).


          "process status change on Jira side
          CALL METHOD zcl_z_jira_charm_integration=>set_jira_status
            EXPORTING
              iv_guid          = hf_instance->change_document_id
              iv_status        = ls_status-stat
            IMPORTING
              es_error_message = ls_error_message.

          IF ls_error_message IS NOT INITIAL.
            " show message in webui
            cl_ai_crm_utility=>show_message( ls_error_message ).
            IF ls_error_message-msgv1 EQ 'STA'.
              "status was already set before?
              "or not? additional field with last sucsessful status transfer to check?
              "what to do?
            ELSE.
              conditions_ok = cl_socm_integration=>false.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
