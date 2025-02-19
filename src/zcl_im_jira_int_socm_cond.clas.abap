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
          TRY.
              CALL METHOD cl_hf_helper=>get_estat_of_change_document
                EXPORTING
                  im_objnr = hf_instance->change_document_id
                IMPORTING
                  ex_estat = DATA(ls_status).
            CATCH
              cx_socm_condition_violated
              cx_socm_declared_exception.
*           no problem --> reason will be analysed later on
          ENDTRY.

          "read status from DB
          SELECT SINGLE stat FROM crm_jest
            WHERE objnr = @hf_instance->change_document_id
            AND inact = ''
            AND stat LIKE 'E%'
            INTO @DATA(lv_stst_db).

          IF lv_stst_db <> ls_status and lv_stst_db <> 'E0001'. "status changed and privies status was not initial.

            "process status change on Jira side
            TRY.
                CALL METHOD zcl_z_jira_charm_integration=>set_jira_status
                  EXPORTING
                    iv_guid          = hf_instance->change_document_id
                    iv_status        = ls_status-stat
                  IMPORTING
                    es_error_message = ls_error_message.
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
              ELSE.
                conditions_ok = cl_socm_integration=>false.
              ENDIF.
            ENDIF.
          ENDIF.
        WHEN 'ZJIRA_TASKS'.
          DATA jira_id TYPE crmt_po_number_sold.
          CALL METHOD zcl_z_jira_charm_integration=>check_jira_task
            EXPORTING
              iv_guid          = hf_instance->change_document_id
            IMPORTING
              es_error_message = ls_error_message
            RECEIVING
              ev_task_id       = jira_id.
          IF jira_id IS NOT INITIAL.
            conditions_ok = cl_socm_integration=>false.
            DATA : lr_global_messages TYPE REF TO cl_crm_genil_global_mess_cont,
                   lr_core            TYPE REF TO cl_crm_bol_core.
            "lv_msg_v1          type clike.
            lr_core = cl_crm_bol_core=>get_instance( ).
            CHECK lr_core IS BOUND.
            lr_global_messages ?= lr_core->get_global_message_cont( ).
            CHECK lr_global_messages IS BOUND.
            "lv_msg_v1 = jira_id.
            CALL METHOD lr_global_messages->add_message
              EXPORTING
                iv_msg_type       = 'E'
                iv_msg_id         = 'ZJIRA_INT'
                iv_msg_number     = '004'
                iv_msg_v1         = jira_id
                iv_show_only_once = 'X'.
          ENDIF.
      ENDCASE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
