class ZCL_Z_JIRA_CHARM_INTEGRATION definition
  public
  final
  create public .

public section.

  class-methods SET_IBASE
    importing
      !IV_GUID type CRMT_OBJECT_GUID
      !IV_IBASE type COMT_PRODUCT_ID .
  class-methods SET_PO_REF
    importing
      !IV_GUID type CRMT_OBJECT_GUID
      !IV_PO_REF type CRMT_PO_NUMBER_SOLD .
  class-methods UPDATE_STATUS
    importing
      !IV_GUID type CRMT_OBJECT_GUID
      !IV_ESTAT type J_ESTAT .
  methods CONSTRUCTOR .
  methods CREATE_NC
    importing
      !IS_ATTRIBUTES type ZJIRA_CHARM_STRU
    returning
      value(RS_ATTRIBUTES_RESP) type ZJIRA_CHARM_STRU .
  methods GET_CONTEXT
    importing
      !IV_CYCLE_ID type CATSRPATX
      !IV_PROCESS_TYPE type CRMT_PROCESS_TYPE_DB
    exporting
      value(EV_CYCLE_ID) type NUMC15
      !EV_SLAN_ID type SLAN_GUID
      !EV_SBRA_ID type SMUD_SBRA_ID
      !EV_IBASE_INSTANCE type IB_INSTANCE
      !EV_PRODUCT_ID type COMT_PRODUCT_ID
      !EV_SID type DIAGLS_TECH_SYST_LONG_SID
      !EV_MANDT type DIAGLS_CLIENT
      !EV_PROJECT type /TMWFLOW/SMI_PROJECT .
  methods CREATE_DC
    importing
      !IS_ATTRIBUTES type ZJIRA_CHARM_STRU
    returning
      value(RS_ATTRIBUTES_RESP) type ZJIRA_CHARM_STRU .
protected section.
private section.
ENDCLASS.



CLASS ZCL_Z_JIRA_CHARM_INTEGRATION IMPLEMENTATION.


  method CONSTRUCTOR.
  endmethod.


  method CREATE_DC.
*        DATA: ls_params          TYPE crmt_name_value_pair,
*          ls_header          TYPE crmst_adminh_btil,
*          ls_activity        TYPE crmst_activityh_btil,
*          ls_status          TYPE crmst_status_btil,
*          ls_service_request TYPE crmst_srvrequesth_btil,
*          ls_text            TYPE crmst_text_btil,
*          ls_subject_single  TYPE crmst_subject_btil,
*          ls_sales_set       TYPE crmst_salesset_btil,
*          ls_partner         TYPE crmst_partner_btil,
*          ls_customerh       TYPE crmst_customerh_btil,
*          ls_context         TYPE aic_s_cr_context_display,
*          ls_scope           TYPE tsocm_cr_context_attr_s.
*
*    DATA: lt_params             TYPE crmt_name_value_pair_tab,
*          lt_message_containers TYPE crmt_genil_mess_cont_tab,
*          lt_messages           TYPE crmt_genil_message_tab.
*
*    DATA: lv_partner_guid TYPE bu_partner_guid,
*          lv_partner      TYPE bu_partner.
*
*    TRY.
*        DATA(lr_crm_bol_core) = cl_crm_bol_core=>get_instance( ).
*        lr_crm_bol_core->load_component_set( 'BT' ).
*        CLEAR: ls_params, lt_params.
** Root Object
*        ls_params-name  = 'PROCESS_TYPE'.
*        ls_params-value =  'ZMTM'.
*        APPEND ls_params TO lt_params.
*        DATA(lr_crm_bol_entity_factory) = lr_crm_bol_core->get_entity_factory( iv_entity_name = 'BTOrder' ).
*        DATA(lr_order)                  = lr_crm_bol_entity_factory->create( lt_params ).
** Order header
*        DATA(lr_order_header) = lr_order->get_related_entity( iv_relation_name = 'BTOrderHeader' ).
*        IF lr_order_header IS NOT BOUND.
*          lr_order_header = lr_order->create_related_entity( iv_relation_name = 'BTOrderHeader').
*        ENDIF.
*        lr_order_header->get_properties( IMPORTING es_attributes = ls_header ).
*        ls_header-process_type = 'ZMTM'.
*        IF strlen( ls_header-description ) > 40.
*          ls_header-description  = is_attributes-short_descr(40).
*        ELSE.
*          ls_header-description  = is_attributes-short_descr.
*        ENDIF.
*        lr_order_header->set_properties( ls_header ).
******* Order activity (priority - not used. Will be in Incident to Urgetn Change)
******        data(lr_activity) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderActivityExt' ).
******        if lr_activity is not bound.
******          lr_activity = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderActivityExt' ).
******        endif.
******        lr_activity->get_properties( importing es_attributes = ls_activity ).
******        ls_activity-priority = iv_priority.
******        lr_activity->set_properties( ls_activity ).
** Status
*        DATA(lr_status_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderStatusSet' ).
*        IF lr_status_set IS NOT BOUND.
*          lr_status_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderStatusSet' ).
*        ENDIF.
*        DATA(lr_status) = lr_status_set->get_related_entity( iv_relation_name = 'BTStatusHAll' ).
*        IF lr_status IS NOT BOUND.
*          lr_status = lr_status_set->create_related_entity( iv_relation_name = 'BTStatusHAll' ).
*        ENDIF.
*        lr_status->get_properties( IMPORTING es_attributes = ls_status ).
*        ls_status-status         = 'E0001'.
*        ls_status-user_stat_proc = 'ZMTMHEAD'.
*        ls_status-activate       = abap_true.
*        lr_status->set_properties( ls_status ).
********* Service request (Impact and urgency) - not used
********        if iv_impact is not initial or iv_urgency is not initial.
********          data(lr_service_request) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderSrvRequestExt' ).
********          if lr_service_request is not bound.
********            lr_service_request = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderSrvRequestExt' ).
********          endif.
********          lr_service_request->get_properties( importing es_attributes = ls_service_request ).
********          ls_service_request-impact  = iv_impact.
********          ls_service_request-urgency = iv_urgency.
********          lr_service_request->set_properties( ls_service_request ).
********        endif.
** Texts
*        IF is_attributes-long_descr IS NOT INITIAL.
*          DATA(lr_text_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderTextSet' ).
*          IF lr_text_set IS NOT BOUND.
*            lr_text_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderTextSet' ).
*          ENDIF.
*          DATA(lr_text) = lr_text_set->get_related_entity( iv_relation_name = 'BTTextHFirst' ).
*          IF lr_text IS NOT BOUND.
*            lr_text = lr_text_set->create_related_entity( iv_relation_name = 'BTTextHFirst' ).
*          ENDIF.
*          lr_text->get_properties( IMPORTING es_attributes = ls_text ).
*          ls_text-tdobject   = 'CRM_ORDERH'.
*          ls_text-tdid       = 'CR01'.
*          ls_text-tdspras    = sy-langu.
*          ls_text-tdstyle    = 'SYSTEM'.
*          ls_text-tdform     = 'SYSTEM'.
*          ls_text-conc_lines = is_attributes-long_descr.
*          lr_text->set_properties( ls_text ).
*        ENDIF.
*** Subject (Multilevel category)
**        if is_attributes-categ is not initial. "or is_attributes-categ2,3,4 is not initial.
**          data(lr_bo_osset) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderBOSSet' ).
**          if lr_bo_osset is not bound.
**            lr_bo_osset = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderBOSSet' ).
**          endif.
**          data(lr_subject) = lr_bo_osset->get_related_entity( iv_relation_name = 'BTSubjectSet_A' ).
**          if lr_subject is not bound.
**            lr_subject = lr_bo_osset->create_related_entity( iv_relation_name = 'BTSubjectSet_A' ).
**          endif.
**          data(lr_subject_single) = lr_subject->get_related_entity( iv_relation_name = 'BTSubjectSingle' ).
**          if lr_subject_single is not bound.
**            lr_subject_single = lr_subject->create_related_entity( iv_relation_name = 'BTSubjectSingle' ).
**          endif.
**          lr_subject_single->get_properties( importing es_attributes = ls_subject_single ).
***-------------------- CATEGORY - SHALL BE 4 values for every category ?
**          ls_subject_single-asp_id = '<TOGG CATEGORIZATION>'. " to
**          "ls_subject_single-cat_id = is_attributes-categ1.
**          "ls_subject_single-cat_id = is_attributes-categ2.
**          "ls_subject_single-cat_id = is_attributes-categ3.
**          "ls_subject_single-cat_id = is_attributes-categ4.
**
**          "ls_subject_single-katalog_type = 'D'.
**          "lr_subject_single->set_properties( ls_subject_single ).
**        endif.
******** Sales (issue Jira)
*******        if is_attributes-jira_id is not initial.
*******          data(lr_sales_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderSalesSet' ).
*******          if lr_sales_set is not bound.
*******            lr_sales_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderSalesSet' ).
*******          endif.
*******          lr_sales_set->get_properties( importing es_attributes = ls_sales_set ).
*******          ls_sales_set-po_number_sold = is_attributes-jira_id.
*******          lr_sales_set->set_properties( ls_sales_set ).
*******        endif.
*
*** Jira Guid
**        data(lr_customerh) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderCustExt' ).
**        if lr_customerh is not bound.
**          lr_customerh = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderCustExt' ).
**        endif.
**        lr_customerh->get_properties( importing es_attributes = ls_customerh ).
**        ls_customerh-zzjira_guid = is_attributes-jira_guid.
**
**        if is_attributes-responsible_service_group is not initial.
**          ls_customerh-zzfld000000 = is_attributes-responsible_service_group.
**        endif.
**
**        if is_attributes-sub_services is not initial.
**          ls_customerh-zzsub_services = is_attributes-sub_services.
**        endif.
**
**        if is_attributes-jira_id is not initial.
**          ls_customerh-zzjira_id = is_attributes-jira_id.
**        endif.
**
**        ls_customerh-zzjira_doc = 'S'.
**
**        lr_customerh->set_properties( ls_customerh ).
*
*
** change cycle, and later TSOCM CR table
*        DATA(lr_cr_context) = lr_order_header->get_related_entity( iv_relation_name = 'BTAICRequestContext' ).
*        IF lr_cr_context IS NOT BOUND.
*          lr_cr_context = lr_order_header->create_related_entity( iv_relation_name = 'BTAICRequestContext' ).
*        ENDIF.
*        lr_cr_context->get_properties(
*          IMPORTING
*            es_attributes = ls_context
*        ).
*        DATA lv_cr_guid TYPE crmt_object_guid.
*        "Data lv_cr_guid ty
*        lv_cr_guid = lr_order_header->get_property_as_string(
*          EXPORTING
*            iv_attr_name      =     'GUID'
*         ).
*
*        DATA lv_jira_cycle TYPE catsrpatx.
*        lv_jira_cycle = is_attributes-change_cycle.
*
*        CALL METHOD me->get_context
*          EXPORTING
*            iv_cycle_id       = lv_jira_cycle
*            iv_process_type   = ls_header-process_type
*          IMPORTING
*            ev_slan_id        = DATA(lv_slan_id)
*            ev_sbra_id        = DATA(lv_sbra_id)
*            ev_ibase_instance = DATA(lv_ibase_instance)
*            ev_product_id     = DATA(lv_product_id)
*            ev_sid            = DATA(lv_sid)
*            ev_mandt          = DATA(lv_mandt)
*            ev_project        = DATA(lv_project)
*            ev_cycle_id       = DATA(lv_cycle).
*
*        ls_context-solution_id = lv_cycle.
*        ls_context-created_guid = lv_cr_guid.
*        ls_context-slan_id = lv_slan_id.
*        ls_context-sbra_id = lv_sbra_id.
*        ls_context-guid = lv_cr_guid.
*        ls_context-item_guid = lv_cr_guid.
*        ls_context-process_type = ls_header-process_type.
*        ls_context-ibase = '000000000000000001'.
*        ls_context-ibase_instance = lv_ibase_instance.
*        ls_context-product_id = lv_product_id.
*        ls_context-sbra_id = ls_context-slan_id.
*        ls_context-slan_id = ls_context-sbra_id.
*        lr_cr_context->set_properties( is_attributes = ls_context ).
*        lr_cr_context->activate_sending(
**             IV_PROPAGATE_2_DEPENDENT = NO_PROPAGATION
*            ).
*        DATA(lr_scope) = lr_order_header->get_related_entity( iv_relation_name = 'BTAICScope' ).
*        IF lr_scope IS NOT BOUND.
*          lr_scope = lr_order_header->create_related_entity( iv_relation_name = 'BTAICScope' ).
*        ENDIF.
*        lr_scope->get_properties(
*          IMPORTING
*            es_attributes = ls_scope
*        ).
**        try.
**            ls_scope-guid = lv_cr_guid.
**            ls_scope-item_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
**            ls_scope-process_type = 'ZMMJ'.
**            ls_scope-ibase = '1'.
**            ls_scope-ibase_instance = lv_ibase_instance.
**            ls_scope-product_id = lv_product_id.
**            ls_scope-created_by = sy-uname.
**            ls_scope-sid = lv_sid.
**            ls_scope-mandt = lv_mandt.
**            lr_scope->set_properties( is_attributes = ls_scope ).
**            lr_scope->activate_sending(
***             IV_PROPAGATE_2_DEPENDENT = NO_PROPAGATION
**            ).
**          catch cx_uuid_error.
**        endtry.
** Partner -> This to be checked, for now maybe not necessary
********        call function 'BP_CENTRALPERSON_GET' exporting iv_username = lv_requester_user_name importing ev_bu_partner_guid = lv_partner_guid exceptions others = 80.
********        select single partner from but000 into lv_partner where partner_guid = lv_partner_guid.
********        if sy-subrc <> 0.
********          ev_has_error = abap_true.
********          perform add_error using sy-msgid sy-msgty sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 changing et_errors.
********        else.
********          data(lr_partner_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderPartnerSet' ).
********          if lr_partner_set is not bound.
********            lr_partner_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderPartnerSet' ).
********          endif.
********          data(lr_partner) = lr_partner_set->get_related_entity( iv_relation_name = 'BTPartner_PFT_0008_MAIN' ).
********          if lr_partner is not bound.
********            lr_partner = lr_partner_set->create_related_entity( iv_relation_name = 'BTPartner_PFT_0008_MAIN' ).
********          endif.
********          lr_partner->get_properties( importing es_attributes = ls_partner ).
********          ls_partner-partner_no    = lv_partner.
********          ls_partner-kind_of_entry = 'C'.
********          ls_partner-partner_fct   = 'SDCR0001'.
********          lr_partner->set_properties( ls_partner ).
********          lr_partner = lr_partner_set->create_related_entity( iv_relation_name = 'BTPartner_PFT_0004_MAIN' ).
********          lr_partner->get_properties( importing es_attributes = ls_partner ).
********          ls_partner-partner_no    = lv_partner.
********          ls_partner-kind_of_entry = 'C'.
********          ls_partner-partner_fct   = 'SDCD0004'.
********          lr_partner->set_properties( ls_partner ).
********        endif.
*
**======================Change Cycle
**----------------------------------
*
*
** Modify object
*        lr_crm_bol_core->modify( ).
*        DATA(lr_container_message) = lr_crm_bol_core->get_message_cont_manager( ).
*        lr_container_message->get_all_message_containers( IMPORTING et_result = lt_message_containers ).
*        rs_attributes_resp-statusresp = 'S'.
*
*        LOOP AT lt_message_containers INTO DATA(lr_message).
*          lr_message->get_messages( EXPORTING iv_message_type = 'E' IMPORTING et_messages = lt_messages ).
*          LOOP AT lt_messages INTO DATA(ls_message).
*            CHECK ls_message-type = 'E'.
*            rs_attributes_resp-statusresp = 'E'.
*            " HAS ERROR Attribute: rs_attributes_resp- = abap_true.
*          ENDLOOP.
*        ENDLOOP.
*        "check rs_attributes_resp-HAS ERROR = abap_false.
**Save and Commit Changes Using Global Transaction Context
*        DATA(lr_transaction) = lr_crm_bol_core->get_transaction( ).
*        IF lr_transaction->check_save_needed( ) = abap_true AND lr_transaction->check_save_possible( ) = abap_true.
*          IF lr_transaction->save( iv_force_save = abap_true ) = abap_true.
*            DATA(lv_commit_work_succeeded) = lr_transaction->commit( ).
*            rs_attributes_resp-solmanguidresp = lr_order_header->get_property_as_string(
*              EXPORTING
*                iv_attr_name      =     'GUID'
*             ).
*            rs_attributes_resp-solmanidresp = lr_order_header->get_property_as_string(
*              EXPORTING
*                iv_attr_name      =     'OBJECT_ID'
*             ).
*            DATA lv_guid TYPE crmt_object_guid.
*            lv_guid = rs_attributes_resp-solmanguidresp.
** TSOCM_CR_CONTEXT table
*
*            SELECT SINGLE * FROM tsocm_cr_context INTO @DATA(ls_tsocm_cr_context) WHERE guid = @lv_guid AND process_type = @ls_header-process_type.
*            ls_tsocm_cr_context-guid = lv_guid.
*            ls_tsocm_cr_context-created_guid = lv_guid.
*            ls_tsocm_cr_context-item_guid = lv_guid.
*            ls_tsocm_cr_context-process_type = ls_header-process_type.
*            ls_tsocm_cr_context-ibase = '000000000000000001'.
*            ls_tsocm_cr_context-ibase_instance = lv_ibase_instance.
*            ls_tsocm_cr_context-product_id = lv_product_id.
*            ls_tsocm_cr_context-project_id =  lv_project.
*            ls_tsocm_cr_context-solution_id = lv_cycle.
*            ls_tsocm_cr_context-slan_id = lv_slan_id.
*            ls_tsocm_cr_context-sbra_id = lv_sbra_id.
*            MODIFY  tsocm_cr_context FROM ls_tsocm_cr_context.
*
*            " URL
*            DATA iv_message_guid TYPE  guid_32.
*            iv_message_guid = lv_guid.
*
*            " URL
*            CALL METHOD cl_ai_crm_ui_api=>wd_start_crm_ui_4_display
*              EXPORTING
*                iv_message_guid = iv_message_guid
*              IMPORTING
*                ev_url          = DATA(lv_urls).
*            rs_attributes_resp-solmanurlresp = lv_urls.
*
*            cl_hf_helper=>get_estat_of_change_document(
*              EXPORTING
**                im_buffer_refresh =     " Data Element for Domain BOOLE: TRUE (="X") and FALSE (=" ")
*                im_objnr          =     lv_guid
*              IMPORTING
*                ex_stsma          =     DATA(lv_stat_prof)
*                ex_estat          =     DATA(lv_stat)
*            ).
*            SELECT txt30 INTO rs_attributes_resp-statusresp FROM tj30t WHERE stsma = lv_stat_prof AND estat = lv_stat AND spras = sy-langu.
*            ENDSELECT.
*            CONCATENATE 'DC with ID ' rs_attributes_resp-solmanidresp ' successfully created on Solution Manager'
*            INTO rs_attributes_resp-messageresp RESPECTING BLANKS.
*
*          ELSE.
*            lr_transaction->rollback( ).
*            rs_attributes_resp-STATUSRESP = 'E'.
*          ENDIF.
*        ENDIF.
*
*
*      CATCH cx_crm_genil_model_error.
*        " HAS ERROR Attribute: rs_attributes_resp- = abap_true.
*        " ADD LOGS HERE
*      CATCH cx_crm_genil_general_error.
*        " HAS ERROR Attribute: rs_attributes_resp- = abap_true.
*        " ADD LOGS HERE
*    ENDTRY.
*
*    "add ibase
*    IF lv_product_id IS NOT INITIAL.
*      CALL METHOD me->set_ibase
*        EXPORTING
*          iv_guid  = lv_guid
*          iv_ibase = lv_product_id.
*    ENDIF.

  endmethod.


  METHOD create_nc.
    DATA: ls_params          TYPE crmt_name_value_pair,
          ls_header          TYPE crmst_adminh_btil,
          ls_activity        TYPE crmst_activityh_btil,
          ls_status          TYPE crmst_status_btil,
          ls_service_request TYPE crmst_srvrequesth_btil,
          ls_text            TYPE crmst_text_btil,
          ls_subject_single  TYPE crmst_subject_btil,
          ls_sales_set       TYPE crmst_salesset_btil,
          ls_partner         TYPE crmst_partner_btil,
          ls_customerh       TYPE crmst_customerh_btil,
          ls_adminh          TYPE crmst_adminh_btil,
          ls_context         TYPE aic_s_cr_context_display,
          ls_scope           TYPE tsocm_cr_context_attr_s.

    DATA: lt_params             TYPE crmt_name_value_pair_tab,
          lt_message_containers TYPE crmt_genil_mess_cont_tab,
          lt_messages           TYPE crmt_genil_message_tab.

    DATA: lv_partner_guid TYPE bu_partner_guid,
          lv_partner      TYPE bu_partner.

    TRY.
        DATA(lr_crm_bol_core) = cl_crm_bol_core=>get_instance( ).
        lr_crm_bol_core->load_component_set( 'BT' ).
        CLEAR: ls_params, lt_params.
* Root Object
        ls_params-name  = 'PROCESS_TYPE'.
        ls_params-value =  'ZSMJ'.
        APPEND ls_params TO lt_params.
        DATA(lr_crm_bol_entity_factory) = lr_crm_bol_core->get_entity_factory( iv_entity_name = 'BTOrder' ).
        DATA(lr_order)                  = lr_crm_bol_entity_factory->create( lt_params ).
* Order header
        DATA(lr_order_header) = lr_order->get_related_entity( iv_relation_name = 'BTOrderHeader' ).
        IF lr_order_header IS NOT BOUND.
          lr_order_header = lr_order->create_related_entity( iv_relation_name = 'BTOrderHeader').
        ENDIF.
        lr_order_header->get_properties( IMPORTING es_attributes = ls_header ).
        ls_header-process_type = 'ZSMJ'.
        IF strlen( ls_header-description ) > 40.
          ls_header-description  = is_attributes-short_descr(40).
        ELSE.
          ls_header-description  = is_attributes-short_descr.
        ENDIF.
        lr_order_header->set_properties( ls_header ).
****** Order activity (priority - not used. Will be in Incident to Urgetn Change)
*****        data(lr_activity) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderActivityExt' ).
*****        if lr_activity is not bound.
*****          lr_activity = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderActivityExt' ).
*****        endif.
*****        lr_activity->get_properties( importing es_attributes = ls_activity ).
*****        ls_activity-priority = iv_priority.
*****        lr_activity->set_properties( ls_activity ).
* Status
        DATA(lr_status_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderStatusSet' ).
        IF lr_status_set IS NOT BOUND.
          lr_status_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderStatusSet' ).
        ENDIF.
        DATA(lr_status) = lr_status_set->get_related_entity( iv_relation_name = 'BTStatusHAll' ).
        IF lr_status IS NOT BOUND.
          lr_status = lr_status_set->create_related_entity( iv_relation_name = 'BTStatusHAll' ).
        ENDIF.
        lr_status->get_properties( IMPORTING es_attributes = ls_status ).
        ls_status-status         = 'E0001'.
        ls_status-user_stat_proc = 'ZSMJHEAD'.
        ls_status-activate       = abap_true.
        lr_status->set_properties( ls_status ).
******** Service request (Impact and urgency) - not used
*******        if iv_impact is not initial or iv_urgency is not initial.
*******          data(lr_service_request) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderSrvRequestExt' ).
*******          if lr_service_request is not bound.
*******            lr_service_request = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderSrvRequestExt' ).
*******          endif.
*******          lr_service_request->get_properties( importing es_attributes = ls_service_request ).
*******          ls_service_request-impact  = iv_impact.
*******          ls_service_request-urgency = iv_urgency.
*******          lr_service_request->set_properties( ls_service_request ).
*******        endif.
* Texts
        IF is_attributes-long_descr IS NOT INITIAL.
          DATA(lr_text_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderTextSet' ).
          IF lr_text_set IS NOT BOUND.
            lr_text_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderTextSet' ).
          ENDIF.
          DATA(lr_text) = lr_text_set->get_related_entity( iv_relation_name = 'BTTextHFirst' ).
          IF lr_text IS NOT BOUND.
            lr_text = lr_text_set->create_related_entity( iv_relation_name = 'BTTextHFirst' ).
          ENDIF.
          lr_text->get_properties( IMPORTING es_attributes = ls_text ).
          ls_text-tdobject   = 'CRM_ORDERH'.
          ls_text-tdid       = 'CR01'.
          ls_text-tdspras    = sy-langu.
          ls_text-tdstyle    = 'SYSTEM'.
          ls_text-tdform     = 'SYSTEM'.
          ls_text-conc_lines = is_attributes-long_descr.
          lr_text->set_properties( ls_text ).
        ENDIF.
** Subject (Multilevel category)
*        if is_attributes-categ is not initial. "or is_attributes-categ2,3,4 is not initial.
*          data(lr_bo_osset) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderBOSSet' ).
*          if lr_bo_osset is not bound.
*            lr_bo_osset = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderBOSSet' ).
*          endif.
*          data(lr_subject) = lr_bo_osset->get_related_entity( iv_relation_name = 'BTSubjectSet_A' ).
*          if lr_subject is not bound.
*            lr_subject = lr_bo_osset->create_related_entity( iv_relation_name = 'BTSubjectSet_A' ).
*          endif.
*          data(lr_subject_single) = lr_subject->get_related_entity( iv_relation_name = 'BTSubjectSingle' ).
*          if lr_subject_single is not bound.
*            lr_subject_single = lr_subject->create_related_entity( iv_relation_name = 'BTSubjectSingle' ).
*          endif.
*          lr_subject_single->get_properties( importing es_attributes = ls_subject_single ).
**-------------------- CATEGORY - SHALL BE 4 values for every category ?
*          ls_subject_single-asp_id = '<TOGG CATEGORIZATION>'. " to
*          "ls_subject_single-cat_id = is_attributes-categ1.
*          "ls_subject_single-cat_id = is_attributes-categ2.
*          "ls_subject_single-cat_id = is_attributes-categ3.
*          "ls_subject_single-cat_id = is_attributes-categ4.
*
*          "ls_subject_single-katalog_type = 'D'.
*          "lr_subject_single->set_properties( ls_subject_single ).
*        endif.
* Sales (issue Jira)
        IF is_attributes-jira_id IS NOT INITIAL.
          DATA(lr_sales_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderSalesSet' ).
          IF lr_sales_set IS NOT BOUND.
            lr_sales_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderSalesSet' ).
          ENDIF.
          lr_sales_set->get_properties( IMPORTING es_attributes = ls_sales_set ).
          ls_sales_set-po_number_sold = is_attributes-jira_guid.
          lr_sales_set->set_properties( ls_sales_set ).
        ENDIF.

        "customer header
        DATA(lr_customerh) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderCustExt' ).
        IF lr_customerh IS NOT BOUND.
          lr_customerh = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderCustExt' ).
        ENDIF.
        lr_customerh->get_properties( IMPORTING es_attributes = ls_customerh ).

        IF is_attributes-project IS NOT INITIAL.
          ls_customerh-zzfld00001j = is_attributes-project.
        ENDIF.
*
*        IF is_attributes-jrelease IS NOT INITIAL.
*          ls_customerh-zzfld00001i = is_attributes-jrelease.
*        ENDIF.
*
*        IF is_attributes-bundle IS NOT INITIAL.
*          ls_customerh-zzfld00000s = is_attributes-bundle.
*        ENDIF.
        lr_customerh->set_properties( ls_customerh ).
*        "Admin header
*        DATA(lr_adminh) = lr_order_header->get_related_entity( iv_relation_name = 'BTAdminH' ).
*        IF lr_adminh IS NOT BOUND.
*          lr_adminh = lr_order_header->create_related_entity( iv_relation_name = 'BTAdminH' ).
*        ENDIF.
*        lr_adminh->get_properties( IMPORTING es_attributes = ls_adminh ).

*        IF is_attributes-project IS NOT INITIAL.
*          ls_customerh-zzfld00001j = is_attributes-project.
*        ENDIF.

* change cycle, and later TSOCM CR table
        DATA(lr_cr_context) = lr_order_header->get_related_entity( iv_relation_name = 'BTAICRequestContext' ).
        IF lr_cr_context IS NOT BOUND.
          lr_cr_context = lr_order_header->create_related_entity( iv_relation_name = 'BTAICRequestContext' ).
        ENDIF.
        lr_cr_context->get_properties(
          IMPORTING
            es_attributes = ls_context
        ).
        DATA lv_cr_guid TYPE crmt_object_guid.
        "Data lv_cr_guid ty
        lv_cr_guid = lr_order_header->get_property_as_string(
          EXPORTING
            iv_attr_name      =     'GUID'
         ).

        DATA lv_jira_cycle TYPE catsrpatx.
        lv_jira_cycle = is_attributes-change_cycle.

        CALL METHOD me->get_context
          EXPORTING
            iv_cycle_id       = lv_jira_cycle
            iv_process_type   = ls_header-process_type
          IMPORTING
            ev_slan_id        = DATA(lv_slan_id)
            ev_sbra_id        = DATA(lv_sbra_id)
            ev_ibase_instance = DATA(lv_ibase_instance)
            ev_product_id     = DATA(lv_product_id)
            ev_sid            = DATA(lv_sid)
            ev_mandt          = DATA(lv_mandt)
            ev_project        = DATA(lv_project)
            ev_cycle_id       = DATA(lv_cycle).

        ls_context-solution_id = lv_cycle.
        ls_context-created_guid = lv_cr_guid.
        ls_context-slan_id = lv_slan_id.
        ls_context-sbra_id = lv_sbra_id.
        ls_context-guid = lv_cr_guid.
        ls_context-item_guid = lv_cr_guid.
        ls_context-process_type = ls_header-process_type.
        ls_context-ibase = '000000000000000001'.
        ls_context-ibase_instance = lv_ibase_instance.
        ls_context-product_id = lv_product_id.
        ls_context-sbra_id = ls_context-slan_id.
        ls_context-slan_id = ls_context-sbra_id.
        lr_cr_context->set_properties( is_attributes = ls_context ).
        lr_cr_context->activate_sending(
*             IV_PROPAGATE_2_DEPENDENT = NO_PROPAGATION
            ).
        DATA(lr_scope) = lr_order_header->get_related_entity( iv_relation_name = 'BTAICScope' ).
        IF lr_scope IS NOT BOUND.
          lr_scope = lr_order_header->create_related_entity( iv_relation_name = 'BTAICScope' ).
        ENDIF.
        lr_scope->get_properties(
          IMPORTING
            es_attributes = ls_scope
        ).
*        try.
*            ls_scope-guid = lv_cr_guid.
*            ls_scope-item_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
*            ls_scope-process_type = 'ZMMJ'.
*            ls_scope-ibase = '1'.
*            ls_scope-ibase_instance = lv_ibase_instance.
*            ls_scope-product_id = lv_product_id.
*            ls_scope-created_by = sy-uname.
*            ls_scope-sid = lv_sid.
*            ls_scope-mandt = lv_mandt.
*            lr_scope->set_properties( is_attributes = ls_scope ).
*            lr_scope->activate_sending(
**             IV_PROPAGATE_2_DEPENDENT = NO_PROPAGATION
*            ).
*          catch cx_uuid_error.
*        endtry.
* Partner -> This to be checked, for now maybe not necessary
*        call function 'BP_CENTRALPERSON_GET' exporting iv_username = lv_requester_user_name importing ev_bu_partner_guid = lv_partner_guid exceptions others = 80.
*        select single partner from but000 into lv_partner where partner_guid = lv_partner_guid.
*        if sy-subrc <> 0.
*          ev_has_error = abap_true.
*          perform add_error using sy-msgid sy-msgty sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 changing et_errors.
*        else.
*          data(lr_partner_set) = lr_order_header->get_related_entity( iv_relation_name = 'BTHeaderPartnerSet' ).
*          if lr_partner_set is not bound.
*            lr_partner_set = lr_order_header->create_related_entity( iv_relation_name = 'BTHeaderPartnerSet' ).
*          endif.
*          data(lr_partner) = lr_partner_set->get_related_entity( iv_relation_name = 'BTPartner_PFT_0008_MAIN' ).
*          if lr_partner is not bound.
*            lr_partner = lr_partner_set->create_related_entity( iv_relation_name = 'BTPartner_PFT_0008_MAIN' ).
*          endif.
*          lr_partner->get_properties( importing es_attributes = ls_partner ).
*          ls_partner-partner_no    = lv_partner.
*          ls_partner-kind_of_entry = 'C'.
*          ls_partner-partner_fct   = 'SDCR0001'.
*          lr_partner->set_properties( ls_partner ).
*          lr_partner = lr_partner_set->create_related_entity( iv_relation_name = 'BTPartner_PFT_0004_MAIN' ).
*          lr_partner->get_properties( importing es_attributes = ls_partner ).
*          ls_partner-partner_no    = lv_partner.
*          ls_partner-kind_of_entry = 'C'.
*          ls_partner-partner_fct   = 'SDCD0004'.
*          lr_partner->set_properties( ls_partner ).
*        endif.

*======================Change Cycle
*----------------------------------


* Modify object
        lr_crm_bol_core->modify( ).
        DATA(lr_container_message) = lr_crm_bol_core->get_message_cont_manager( ).
        lr_container_message->get_all_message_containers( IMPORTING et_result = lt_message_containers ).
        rs_attributes_resp-statusresp = 'S'.

        LOOP AT lt_message_containers INTO DATA(lr_message).
          lr_message->get_messages( EXPORTING iv_message_type = 'E' IMPORTING et_messages = lt_messages ).
          LOOP AT lt_messages INTO DATA(ls_message).
            CHECK ls_message-type = 'E'.
            rs_attributes_resp-statusresp = 'E'.
            " HAS ERROR Attribute: rs_attributes_resp- = abap_true.
          ENDLOOP.
        ENDLOOP.

        "check rs_attributes_resp-HAS ERROR = abap_false.
*Save and Commit Changes Using Global Transaction Context
        DATA(lr_transaction) = lr_crm_bol_core->get_transaction( ).
        IF lr_transaction->check_save_needed( ) = abap_true AND lr_transaction->check_save_possible( ) = abap_true.
          IF lr_transaction->save( iv_force_save = abap_true ) = abap_true.
            DATA(lv_commit_work_succeeded) = lr_transaction->commit( ).
            rs_attributes_resp-solmanguidresp = lr_order_header->get_property_as_string(
              EXPORTING
                iv_attr_name      =     'GUID'
             ).
            rs_attributes_resp-solmanidresp = lr_order_header->get_property_as_string(
              EXPORTING
                iv_attr_name      =     'OBJECT_ID'
             ).
            DATA lv_guid TYPE crmt_object_guid.
            lv_guid = rs_attributes_resp-solmanguidresp.
* TSOCM_CR_CONTEXT table

            SELECT SINGLE * FROM tsocm_cr_context INTO @DATA(ls_tsocm_cr_context) WHERE guid = @lv_guid AND process_type = @ls_header-process_type.
            ls_tsocm_cr_context-guid = lv_guid.
            ls_tsocm_cr_context-created_guid = lv_guid.
            ls_tsocm_cr_context-item_guid = lv_guid.
            ls_tsocm_cr_context-process_type = ls_header-process_type.
            ls_tsocm_cr_context-ibase = '000000000000000001'.
            ls_tsocm_cr_context-ibase_instance = lv_ibase_instance.
            ls_tsocm_cr_context-product_id = lv_product_id.
            ls_tsocm_cr_context-project_id =  lv_project.
            ls_tsocm_cr_context-solution_id = lv_cycle.
            ls_tsocm_cr_context-slan_id = lv_slan_id.
            ls_tsocm_cr_context-sbra_id = lv_sbra_id.
            MODIFY  tsocm_cr_context FROM ls_tsocm_cr_context.

            " URL
            DATA iv_message_guid TYPE	guid_32.
            iv_message_guid = lv_guid.

            " URL
            CALL METHOD cl_ai_crm_ui_api=>wd_start_crm_ui_4_display
              EXPORTING
                iv_message_guid = iv_message_guid
              IMPORTING
                ev_url          = DATA(lv_urls).
            rs_attributes_resp-solmanurlresp = lv_urls.

            cl_hf_helper=>get_estat_of_change_document(
              EXPORTING
*                im_buffer_refresh =     " Data Element for Domain BOOLE: TRUE (="X") and FALSE (=" ")
                im_objnr          =     lv_guid
              IMPORTING
                ex_stsma          =     DATA(lv_stat_prof)
                ex_estat          =     DATA(lv_stat)
            ).
            SELECT txt30 INTO rs_attributes_resp-statusresp FROM tj30t WHERE stsma = lv_stat_prof AND estat = lv_stat AND spras = sy-langu.
            ENDSELECT.
            CONCATENATE 'NC with ID ' rs_attributes_resp-solmanidresp ' successfully created on Solution Manager'
            INTO rs_attributes_resp-messageresp RESPECTING BLANKS.

          ELSE.
            lr_transaction->rollback( ).
            rs_attributes_resp-statusresp = 'E'.
          ENDIF.
        ENDIF.


      CATCH cx_crm_genil_model_error.
        " HAS ERROR Attribute: rs_attributes_resp- = abap_true.
        " ADD LOGS HERE
      CATCH cx_crm_genil_general_error.
        " HAS ERROR Attribute: rs_attributes_resp- = abap_true.
        " ADD LOGS HERE
    ENDTRY.

*    " add jira id
*    DATA lv_jira_id TYPE crmt_po_number_sold.
*    lv_jira_id = is_attributes-jira_guid.
*    CALL METHOD zcl_z_jira_charm_integration=>set_po_ref
*      EXPORTING
*        iv_guid   = lv_cr_guid
*        iv_po_ref = lv_jira_id.

    "add ibase
    IF lv_product_id IS NOT INITIAL.
      CALL METHOD me->set_ibase
        EXPORTING
          iv_guid  = lv_guid
          iv_ibase = lv_product_id.
    ENDIF.

    DATA lt_guid TYPE crmt_object_guid_tab.
    APPEND lv_guid TO lt_guid .
    CALL FUNCTION 'CRM_ORDER_SAVE'
      EXPORTING
        it_objects_to_save = lt_guid
      EXCEPTIONS
        document_not_saved = 1
        OTHERS             = 2.
    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD get_context.
    DATA:
      lv_cycle              TYPE crmt_object_id_db,
      lv_ibase              TYPE ib_ibase,
      lv_product_id         TYPE comt_product_id,
      is_refobj             TYPE crmt_refobj_com,
      cv_log_handle         TYPE balloghndl,
      lv_search_comp_detail TYPE ibap_comp1,
      lv_found_comp_detail  TYPE ibap_dat1,
      lv_comp_detail        TYPE ibap_comp2.

*    SELECT SINGLE jirastat FROM zjira_mapping INTO @lv_cycle
*    WHERE syst = @sy-sysid
*    AND process_type = @iv_process_type
*    AND jdescription = @iv_cycle_id
*    AND direction = 'I'
*    AND j_int_param = 'C'.

    ev_cycle_id = lv_cycle.

    "Get values for cycle
    SELECT SINGLE * FROM aic_release_cycl INTO @DATA(lv_rel)
    WHERE release_crm_id = @lv_cycle.

    SELECT SINGLE * FROM tsocm_cr_context INTO @DATA(lv_context)
    WHERE guid = @lv_rel-release_crm_guid.

    "Set values for cycle

    ev_slan_id = lv_rel-release_component.
    ev_sbra_id = lv_rel-branch_id.
    ev_project = lv_rel-smi_project.

    "set ibase

    ev_mandt = iv_cycle_id+4.
    ev_sid =  iv_cycle_id+0(3).

    SELECT SINGLE ibase_instance, product_id FROM tsocm_cr_context
      WHERE sid = @ev_sid AND mandt = @ev_mandt AND project_id = @ev_project
      AND ibase_instance > 0
      INTO ( @ev_ibase_instance, @ev_product_id ).


  ENDMETHOD.


  method SET_IBASE.

    data: z_ibase               type ib_ibase,
          z_product_id          type comt_product_id,
          is_refobj             type crmt_refobj_com,
          cv_log_handle         type balloghndl,
          lv_product_id         type string,
          lv_search_comp_detail type ibap_comp1,
          lv_found_comp_detail  type ibap_dat1,
          lv_comp_detail        type ibap_comp2,
          iv_1o_api             type ref to cl_ags_crm_1o_api,
          lv_log_handle         type balloghndl.


    select product_guid into @data(lv_p_guid16) from comm_product where product_id = @iv_ibase.

      lv_search_comp_detail-object_guid = lv_p_guid16.

      call function 'CRM_IBASE_COMP_FIND'
        exporting
          i_comp_det        = lv_search_comp_detail
        importing
          e_comp            = lv_found_comp_detail
        exceptions
          not_found         = 1
          several_instances = 2
          others            = 3.
      if sy-subrc <> 0.
        continue.  "with next entry
      endif.
    endselect.

    is_refobj-ref_guid    = iv_guid.
    is_refobj-product_id  = iv_ibase.
    is_refobj-ib_instance = lv_found_comp_detail-ibase.
    is_refobj-ib_ibase    = lv_found_comp_detail-instance.

    " get customer header
    cl_ags_crm_1o_api=>get_instance(
        exporting
        iv_header_guid                = iv_guid
        iv_process_mode               = cl_ags_crm_1o_api=>ac_mode-change  " Processing Mode of Transaction
      importing
        eo_instance                   = iv_1o_api
      exceptions
        invalid_parameter_combination = 1
        error_occurred                = 2
        others                        = 3 ).
    if sy-subrc <> 0.
    endif.

    call method iv_1o_api->set_refobj
      exporting
        is_refobj         = is_refobj
      changing
        cv_log_handle     = cv_log_handle
      exceptions
        document_locked   = 1
        error_occurred    = 2
        no_authority      = 3
        no_change_allowed = 4
        others            = 5.
    if sy-subrc <> 0.
      "cs_cd-error_code = ''.
      "cs_cd-error_text = ''.
      "exit.
    endif.

    "iv_1o_api->save( changing cv_log_handle = lv_log_handle ).
  endmethod.


  METHOD set_po_ref.
    DATA: lt_input_fields  TYPE  crmt_input_field_tab,
          ls_input_fields  TYPE  crmt_input_field,
          lt_nametab       TYPE  crmt_input_field_names_tab,
          ls_nametab       TYPE  crmt_input_field_names,
          lt_sales         TYPE  crmt_sales_comt,
          ls_sales         TYPE  crmt_sales_com,
          lv_guid          TYPE  crmt_object_guid,
          ls_saved_objects TYPE  crmt_return_objects_struc,
          lt_sales_r       TYPE  crmt_sales_wrkt.

    lv_guid = iv_guid.

    ls_nametab-fieldname = 'PO_NUMBER_SOLD'.
    APPEND ls_nametab TO lt_nametab.
    ls_input_fields-ref_kind = 'A'.
    ls_input_fields-ref_guid = lv_guid.
    ls_input_fields-objectname = 'SALES'.
    ls_input_fields-logical_key = space.
    ls_input_fields-field_names[] = lt_nametab[].
    INSERT ls_input_fields INTO TABLE lt_input_fields.
    ls_sales-ref_guid = lv_guid.
    ls_sales-ref_kind = 'A'.
    ls_sales-po_number_sold = iv_po_ref.
    INSERT ls_sales INTO TABLE lt_sales.

    CALL FUNCTION 'CRM_ORDER_MAINTAIN'
      EXPORTING
        it_sales          = lt_sales  " Law Reference Header Segment Communication table
      CHANGING
        ct_input_fields   = lt_input_fields
      EXCEPTIONS
        error_occurred    = 1
        document_locked   = 2
        no_change_allowed = 3
        no_authority      = 4
        OTHERS            = 5.

    DATA lt_guid TYPE crmt_object_guid_tab.
    APPEND lv_guid TO lt_guid .

    CALL FUNCTION 'CRM_ORDER_READ'
      EXPORTING
        IT_HEADER_GUID       = lt_guid
        iv_mode              = 'C'
      IMPORTING
        ET_SALES             = lt_sales_r
      EXCEPTIONS
        document_not_found   = 1
        error_occurred       = 2
        document_locked      = 3
        no_change_authority  = 4
        no_display_authority = 5
        no_change_allowed    = 6
        OTHERS               = 7.
    "


  ENDMETHOD.


  method UPDATE_STATUS.

  endmethod.
ENDCLASS.
