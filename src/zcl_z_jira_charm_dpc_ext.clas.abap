class ZCL_Z_JIRA_CHARM_DPC_EXT definition
  public
  inheriting from ZCL_Z_JIRA_CHARM_DPC
  create public .

public section.
protected section.

  methods ZDOCUMENTSSET_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_JIRA_CHARM_DPC_EXT IMPLEMENTATION.


  METHOD zdocumentsset_create_entity.
    INCLUDE crm_mode_con.
    DATA: lo_msg_container   TYPE REF TO /iwbep/if_message_container,
          lo_msg             TYPE REF TO /iwbep/if_message_container,
          lo_jira_api        TYPE REF TO zcl_z_jira_charm_integration,
          ls_attributes_resp TYPE zcl_z_jira_charm_mpc=>ts_zdocuments.

    lo_msg_container = me->mo_context->get_message_container( ).


    io_data_provider->read_entry_data(
      IMPORTING
        es_data                      =  er_entity
    ).

    IF er_entity IS INITIAL.
      "raise /iwbep/cx_mgw_busi_exception.
    ENDIF.

    " 1. check if already CR exists related to Jira GUID. If yes - will be update of existing one
    "JIRA GUID -  to be done
    CREATE OBJECT lo_jira_api.
*    SELECT SINGLE * FROM crmd_customer_h INTO @DATA(ls_customer_h) WHERE zzjira_guid = @er_entity-jira_guid. "#EC CI_NOFIELD

    IF sy-subrc = 0.
      " update of existing DOC
*      data(lv_process_type) = cl_hf_helper=>get_proc_type_of_chng_doc( im_change_document_id = ls_customer_h-guid ).
      " in case of CR and of CR = 'Being Implemented', related CDs need to be updated
*      data lv_rfc_in_implement type boolean.
*      if lv_process_type = 'ZMCR'.
*        cl_hf_helper=>get_estat_of_change_document(
*          exporting
**           im_buffer_refresh =     " Data Element for Domain BOOLE: TRUE (="X") and FALSE (=" ")
*            im_objnr          =     ls_customer_h-guid
*          importing
*            ex_estat          =     data(lv_rfc_stat)
*            ).
*
*        if lv_rfc_stat = 'E0015'.
*          if er_entity-status = 'Implementation'.
*            lo_jira_api->send_notification( iv_rfc_guid = ls_customer_h-guid ).
*            " send notification to developer that status reset back on Jira
*          else.
*            data(lt_succ_docs) = cl_hf_helper=>get_sucdocs_of_chng_doc( im_change_document_id = ls_customer_h-guid ).
*            lv_rfc_in_implement = abap_true.
*
*            loop at lt_succ_docs into data(lv_succ_doc_guid).
*
*              if ( cl_hf_helper=>get_proc_type_of_chng_doc( im_change_document_id = lv_succ_doc_guid ) ) = 'ZMMJ'.
*
*                " switch status of NC docuemnt
*                select single estat from zjira_mapping into @data(lv_estatus)
*                  where syst = @sy-sysid
*                    and process_type = 'ZMMJ'
*                    and direction = 'I'
*                    and jdescription = @er_entity-status
*                    and j_int_param = 'P'.
*                if lv_estatus is initial.
*                  "exception - missing cuatomizing
*                endif.
*                data lv_action_check type ppfdtt.
*                " E0016 In UAT  ZMMJ_ZSET_TO_UAT
*                " E0009 Succesfullt Tested  ZMMJ_TESTED_AND_OK_MJ
*                " E0017 Deployent Approved ZMMJ_ZSET_TO_DEPL_APPROVED
*
*                case lv_estatus.
*                  when 'E0016'. lv_action_check = 'ZMMJ_ZSET_TO_UAT'.
*                  when 'E0009'. lv_action_check = 'ZMMJ_TESTED_AND_OK_MJ'.
*                  when 'E0017'. lv_action_check = 'ZMMJ_ZSET_TO_DEPL_APPROVED'.
*                endcase.
*
*                ls_attributes_resp = lo_jira_api->update_status(
*                  exporting
*                    iv_guid            =   lv_succ_doc_guid
*                    iv_estat           =   lv_estatus
*                    iv_action_name_check = lv_action_check ).
*              endif. " ZMMJ
*            endloop. " succ docs of RfC - Normal Changes ZMMJ
*          endif. " change status or send notification if revert back to implement
*        endif. "RFC in Being Implemented E0015
*      endif. "ZMCR
*
*    "save BRD and FSTS URL links:
*      lo_jira_api->add_url(
*        exporting
*          iv_url             = er_entity-brd_url
*          iv_url_name        = 'BRD Document'
*          iv_url_description = 'A link for BRD Document'
*          iv_order_guid      = ls_customer_h-guid
*      ).
*
*      lo_jira_api->add_url(
*        exporting
*          iv_url             = er_entity-fsts_url
*          iv_url_name        = 'FSTS Document'
*          iv_url_description = 'A link for FSTS document'
*          iv_order_guid      = ls_customer_h-guid
*      ).
*
*      if lv_rfc_in_implement = abap_false.
*        select single estat from zjira_mapping into @data(lv_estat)
*          where syst = @sy-sysid
*          and process_type = @lv_process_type
*          and direction = 'I'
*          and jdescription = @er_entity-status
*          and j_int_param = 'S'.
*        if lv_estat is initial.
*          " exception - missing cuatomizing
*        endif.
*
*        ls_attributes_resp = lo_jira_api->update_status(
*          exporting
*            iv_guid            =   ls_customer_h-guid
*            iv_estat           =   lv_estat
*       ).
*      endif.
**!!!CLEAR ER_ENTITY!!!
*      clear er_entity.
*      concatenate 'CR linked with Jira guid ' er_entity-jira_guid ' exists and will be updated.' into er_entity-messageresp.
*      er_entity-statusopresp = 'I'.
*
*      call method me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
*        receiving
*          ro_message_container = lo_msg.
*
*      if ls_attributes_resp-statusopresp = 'S'.
*        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
*          exporting
*            iv_msg_type               =  'S'
*            iv_msg_text               =   'Success'"ls_attributes_resp-msg_resp
**              iv_error_category         =     " Error category - defined by GCS_ERROR_CATEGORY
**              iv_is_leading_message     = ABAP_TRUE    " Flags this message as the leading error message
**              iv_entity_type            =     " Entity type/name
**              it_key_tab                =     " Entity key as name-value pair
*            iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
**              iv_message_target         =     " Target (reference) (e.g. Property ID) of a message
*      ).
*
*
*      elseif ls_attributes_resp-statusopresp = 'E'.
*
*        call method me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
*          receiving
*            ro_message_container = lo_msg.
*
*        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
*        exporting
*          iv_msg_type               =  'E'
*          iv_msg_text               =   'Error'"ls_attributes_resp-msg_resp
**                iv_error_category         =     " Error category - defined by GCS_ERROR_CATEGORY
**                iv_is_leading_message     = ABAP_TRUE    " Flags this message as the leading error message
**                iv_entity_type            =     " Entity type/name
**                it_key_tab                =     " Entity key as name-value pair
*          iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
**                iv_message_target         =     " Target (reference) (e.g. Property ID) of a message
*    ).
*   ENDIF.
    ELSE.
      " 2. Create new Document
      " creaete new
      CASE er_entity-jira_issue_type.
*        when 'Change'.   "ZMCR
*          ls_attributes_resp = lo_jira_api->create_rfc( is_attributes = er_entity ).
        WHEN 'Incident'. "YMHF
          ls_attributes_resp = lo_jira_api->create_dc( is_attributes = er_entity ).
        WHEN 'Story'.    "ZMMJ
          ls_attributes_resp = lo_jira_api->create_nc( is_attributes = er_entity ).
        WHEN OTHERS.
      ENDCASE.

      CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
        RECEIVING
          ro_message_container = lo_msg.

      IF ls_attributes_resp-statusresp = 'S' .

        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
          EXPORTING
            iv_msg_type               =  'S'
            iv_msg_text               =   'Success'"ls_attributes_resp-msg_resp
*              iv_error_category         =     " Error category - defined by GCS_ERROR_CATEGORY
*              iv_is_leading_message     = ABAP_TRUE    " Flags this message as the leading error message
*              iv_entity_type            =     " Entity type/name
*              it_key_tab                =     " Entity key as name-value pair
            iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
*              iv_message_target         =     " Target (reference) (e.g. Property ID) of a message
      ).
      ELSE.
        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
            EXPORTING
              iv_msg_type               =  'E'
              iv_msg_text               =   'Error'"ls_attributes_resp-msg_resp
*                            iv_error_category         =     " Error category - defined by GCS_ERROR_CATEGORY
*                            iv_is_leading_message     = ABAP_TRUE    " Flags this message as the leading error message
*                            iv_entity_type            =     " Entity type/name
*                            it_key_tab                =     " Entity key as name-value pair
              iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
*                            iv_message_target         =     " Target (reference) (e.g. Property ID) of a message
            ).
      ENDIF.
    ENDIF. " create - update
*
    CLEAR er_entity.

    er_entity-solmanguidresp = ls_attributes_resp-solmanguidresp.
    er_entity-solmanidresp = ls_attributes_resp-solmanidresp.
    er_entity-messageresp = ls_attributes_resp-messageresp.
    er_entity-statusresp = ls_attributes_resp-statusresp.

  ENDMETHOD.
ENDCLASS.
