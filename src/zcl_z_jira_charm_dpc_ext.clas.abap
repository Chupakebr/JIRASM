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
          lv_jira_id         TYPE crmt_po_number_sold,
          ls_attributes_resp TYPE zcl_z_jira_charm_mpc=>ts_zdocuments.

    lo_msg_container = me->mo_context->get_message_container( ).
    lv_jira_id = er_entity-jira_guid.


    io_data_provider->read_entry_data(
      IMPORTING
        es_data                      =  er_entity
    ).

    IF er_entity IS INITIAL.
      "raise /iwbep/cx_mgw_busi_exception.
    ENDIF.

    " 1. check if already CR exists related to Jira GUID. If yes - will be update of existing one
    CREATE OBJECT lo_jira_api.
    SELECT SINGLE t_l~guid_hi FROM crmd_link AS t_l LEFT JOIN
      crmd_sales AS t_s ON t_l~guid_set = t_s~guid INTO @DATA(lv_guid)
      WHERE t_s~po_number_sold = @er_entity-jira_guid AND po_number_sold IS NOT NULL. "#EC CI_NOFIELD

    IF sy-subrc = 0.
      "1. update of existing DOC
      DATA(lv_process_type) = cl_hf_helper=>get_proc_type_of_chng_doc( im_change_document_id = lv_guid ).
      SELECT SINGLE sm_status, sm_action FROM zjira_mapping INTO ( @DATA(lv_estat), @DATA(lv_action_check) )
        WHERE syst = @sy-sysid
        AND process_type = @lv_process_type
        AND direction = 'I'
        AND jira_status = @er_entity-status.
      IF lv_estat IS INITIAL.
        " exception - missing cuatomizing
      ENDIF.

*      "DATA lv_action_check TYPE ppfdtt.
*      " E0016 In UAT  ZMMJ_ZSET_TO_UAT
*      " E0009 Succesfullt Tested  ZMMJ_TESTED_AND_OK_MJ
*      " E0017 Deployent Approved ZMMJ_ZSET_TO_DEPL_APPROVED
*
*      CASE lv_estatus.
*        WHEN 'E0016'. lv_action_check = 'ZMMJ_ZSET_TO_UAT'.
*        WHEN 'E0009'. lv_action_check = 'ZMMJ_TESTED_AND_OK_MJ'.
*        WHEN 'E0017'. lv_action_check = 'ZMMJ_ZSET_TO_DEPL_APPROVED'.
*      ENDCASE.

      ls_attributes_resp = lo_jira_api->update_status(
        EXPORTING
          iv_guid            =   lv_guid
          iv_estat           =   lv_estat
          iv_action_name_check = lv_action_check ).
      " ZMMJ
      "Prepering reply
      CLEAR er_entity.
      er_entity-jira_guid = lv_jira_id.
      CONCATENATE 'CR linked with Jira guid ' er_entity-jira_guid ' exists and will be updated.' INTO er_entity-messageresp.
      er_entity-statusresp = 'I'.

      CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
        RECEIVING
          ro_message_container = lo_msg.

      IF ls_attributes_resp-statusresp = 'S'.
        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
          EXPORTING
            iv_msg_type               =  'S'
            iv_msg_text               =  'Success'"ls_attributes_resp-msg_resp
            iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).


      ELSEIF ls_attributes_resp-statusresp = 'E'.

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
          RECEIVING
            ro_message_container = lo_msg.

        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
        EXPORTING
          iv_msg_type               =  'E'
          iv_msg_text               =   'Error'"ls_attributes_resp-msg_resp
          iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
    ).
      ENDIF.
      er_entity-solmanguidresp = lv_guid.
      er_entity-messageresp = ls_attributes_resp-messageresp.
      er_entity-statusresp = ls_attributes_resp-statusresp.
      "er_entity-solmanidresp = ls_attributes_resp-solmanidresp.

    ELSE.
      " 2. Create new Document
      " creaete new
      CASE er_entity-jira_issue_type.
        WHEN 'Incident'. "ZMTM
          ls_attributes_resp = lo_jira_api->create_cd( is_attributes = er_entity iv_process_type = 'ZMTM').
        WHEN 'Story'.    "ZSMJ
          ls_attributes_resp = lo_jira_api->create_cd( is_attributes = er_entity iv_process_type = 'ZSMJ').
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
            iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).
      ELSE.
        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
            EXPORTING
              iv_msg_type               =  'E'
              iv_msg_text               =   'Error'"ls_attributes_resp-msg_resp
              iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
            ).
      ENDIF.

*
      CLEAR er_entity.

      er_entity-solmanguidresp = ls_attributes_resp-solmanguidresp.
      er_entity-solmanidresp = ls_attributes_resp-solmanidresp.
      er_entity-messageresp = ls_attributes_resp-messageresp.
      er_entity-statusresp = ls_attributes_resp-statusresp.
    ENDIF. " create - update

  ENDMETHOD.
ENDCLASS.
