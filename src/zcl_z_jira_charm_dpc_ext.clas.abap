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


  method zdocumentsset_create_entity.
    include crm_mode_con.
    data: lo_msg_container   type ref to /iwbep/if_message_container,
          lo_msg             type ref to /iwbep/if_message_container,
          lo_jira_api        type ref to zcl_z_jira_charm_integration,
          lv_jira_id         type crmt_po_number_sold,
          ls_attributes_resp type zcl_z_jira_charm_mpc=>ts_zdocuments.

    data iv_message_guid type	guid_32.

    lo_msg_container = me->mo_context->get_message_container( ).
    lv_jira_id = er_entity-jira_guid.


    io_data_provider->read_entry_data(
      importing
        es_data                      =  er_entity
    ).

    if er_entity is initial.
      "raise /iwbep/cx_mgw_busi_exception.
    endif.

    " 1. check if already CR exists related to Jira GUID. If yes - will be update of existing one
    create object lo_jira_api.
    select single t_l~guid_hi from crmd_link as t_l left join
      crmd_sales as t_s on t_l~guid_set = t_s~guid into @data(lv_guid)
      where t_s~po_number_sold = @er_entity-jira_guid and po_number_sold is not null. "#EC CI_NOFIELD

    if sy-subrc = 0.

      ls_attributes_resp = lo_jira_api->update_cd( is_attributes = er_entity iv_guid = lv_guid ).
      "1. update of existing DOC
      data(lv_process_type) = cl_hf_helper=>get_proc_type_of_chng_doc( im_change_document_id = lv_guid ).
      select single sm_status, sm_action from zjira_mapping into ( @data(lv_estat), @data(lv_action_check) )
        where syst = @sy-sysid
        and process_type = @lv_process_type
        and direction = 'I'
        and jira_status = @er_entity-status.
      if lv_estat is initial.
        " exception - missing cuatomizing
      endif.

      ls_attributes_resp = lo_jira_api->update_status(
        exporting
          iv_guid            =   lv_guid
          iv_estat           =   lv_estat
          iv_action_name_check = lv_action_check ).
      " ZMMJ
      "Prepering reply
      clear er_entity.
      er_entity-jira_guid = lv_jira_id.
      concatenate 'CR linked with Jira guid ' er_entity-jira_guid ' exists and will be updated.' into er_entity-messageresp.
      er_entity-statusresp = 'I'.

      call method me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
        receiving
          ro_message_container = lo_msg.

      if ls_attributes_resp-statusresp = 'S'.
        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
          exporting
            iv_msg_type               =  'S'
            iv_msg_text               =  'Success'"ls_attributes_resp-msg_resp
            iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).


      elseif ls_attributes_resp-statusresp = 'E'.

        call method me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
          receiving
            ro_message_container = lo_msg.

        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
        exporting
          iv_msg_type               =  'E'
          iv_msg_text               =   'Error'"ls_attributes_resp-msg_resp
          iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
    ).
      endif.

      select single object_id from crmd_orderadm_h where guid = @lv_guid into @data(lv_sm_id) .
      if lv_sm_id is not initial.
        er_entity-solmanidresp = lv_sm_id.
      endif.

      er_entity-solmanguidresp = lv_guid.
      er_entity-messageresp = ls_attributes_resp-messageresp.
      er_entity-statusresp = ls_attributes_resp-statusresp.

      " URL
      if lv_guid is not initial.
        iv_message_guid = lv_guid.

        call method cl_ai_crm_ui_api=>wd_start_crm_ui_4_display
          exporting
            iv_message_guid = iv_message_guid
          importing
            ev_url          = data(lv_urls_o).
        er_entity-solmanurlresp = lv_urls_o.
      endif.


    else.
      " 2. Create new Document
      " creaete new
      case er_entity-jira_issue_type.
        when 'Incident'. "ZMTM
          ls_attributes_resp = lo_jira_api->create_cd( is_attributes = er_entity iv_process_type = 'ZMTM').
        when 'Story'.    "ZSMJ
          ls_attributes_resp = lo_jira_api->create_cd( is_attributes = er_entity iv_process_type = 'ZSMJ').
        when others.
      endcase.

      call method me->/iwbep/if_mgw_conv_srv_runtime~get_message_container "#EC CI_NO_OBJ_INS_C
        receiving
          ro_message_container = lo_msg.

      if ls_attributes_resp-statusresp = 'S' .

        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
          exporting
            iv_msg_type               =  'S'
            iv_msg_text               =   'Success'"ls_attributes_resp-msg_resp
            iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
      ).
      else.
        lo_msg->add_message_text_only(             "#EC CI_NO_OBJ_INS_C
            exporting
              iv_msg_type               =  'E'
              iv_msg_text               =   'Error'"ls_attributes_resp-msg_resp
              iv_add_to_response_header = abap_true    " Flag for adding or not the message to the response header
            ).
      endif.

*
      clear er_entity.

      er_entity-solmanguidresp = ls_attributes_resp-solmanguidresp.
      er_entity-solmanidresp = ls_attributes_resp-solmanidresp.
      er_entity-messageresp = ls_attributes_resp-messageresp.
      er_entity-statusresp = ls_attributes_resp-statusresp.
      " URL
      if ls_attributes_resp-solmanguidresp is not initial.
        iv_message_guid = ls_attributes_resp-solmanguidresp.

        call method cl_ai_crm_ui_api=>wd_start_crm_ui_4_display
          exporting
            iv_message_guid = iv_message_guid
          importing
            ev_url          = data(lv_urls).
        er_entity-solmanurlresp = lv_urls.
      endif. " create - update
    endif.

  endmethod.
ENDCLASS.
