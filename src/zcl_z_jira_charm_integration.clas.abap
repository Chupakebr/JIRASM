class ZCL_Z_JIRA_CHARM_INTEGRATION definition
  public
  final
  create public .

public section.

  class-methods SEND_NOTIFICATION
    importing
      !IV_RFC_GUID type CRMT_OBJECT_GUID
    returning
      value(RV_STATUS) type PPFDTSTAT .
  class-methods SET_STATUS_BY_JOB
    importing
      !IV_ORDER_GUID type CRMT_OBJECT_GUID
    returning
      value(RV_SUCCESS) type BOOLEAN .
  class-methods GET_JIRA_ID
    importing
      !IV_GUID type CRMT_OBJECT_GUID
    exporting
      !EV_JIRA_ID type CRMT_PO_NUMBER_SOLD .
  class-methods POST
    importing
      !IV_BODY type STRING
      !IV_URI type STRING
    exporting
      !EV_HTTP_RESPONSE type STRING
      !EV_HTTP_RESPONSE_STATUS_CODE type STRING .
  class-methods SET_JIRA_STATUS
    importing
      !IV_GUID type CRMT_OBJECT_GUID
      !IV_STATUS type CRM_J_STATUS
    exporting
      !ES_ERROR_MESSAGE type SYMSG .
  class-methods SET_STATUS_BY_PPF
    importing
      !IV_OBJECT_GUID type CRMT_OBJECT_GUID
      !IV_ESTATUS type J_ESTAT
    returning
      value(RV_EXEC_STATUS) type PPFDTSTAT .
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
      !IV_ESTAT type J_ESTAT
      !IV_ACTION_NAME_CHECK type PPFDTT
    returning
      value(RS_ATTRIBUTES_RESP) type ZJIRA_CHARM_STRU .
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


  METHOD get_jira_id.

    SELECT SINGLE t_s~po_number_sold FROM crmd_link AS t_l LEFT JOIN
      crmd_sales AS t_s ON t_l~guid_set = t_s~guid INTO @ev_jira_id
    WHERE t_l~guid_hi = @iv_guid AND po_number_sold IS NOT NULL. "#EC CI_NOFIELD

  ENDMETHOD.


  method post.

    data: lo_http_client     type ref to if_http_client,
          lo_rest_client     type ref to cl_rest_http_client,
          lv_url             type        string,
          http_status        type        string,
          token              type        string,
          agreements         type        string,
          lo_response        type ref to if_rest_entity,
          lv_header_guid     type crmt_object_guid,
          lv_object_type_ref type swo_objtyp,
          iv_transactionid   type string,
          lv_message         type i.

* Create HTTP intance using RFC restination created

    cl_http_client=>create_by_destination(
     exporting
       destination              = 'LAYER7'            " Logical destination (specified in function call)
     importing
       client                   = lo_http_client    " HTTP Client Abstraction
     exceptions
       argument_not_found       = 1
       destination_not_found    = 2
       destination_no_authority = 3
       plugin_not_active        = 4
       internal_error           = 5
       others                   = 6
    ).


* Create REST client instance
    create object lo_rest_client
      exporting
        io_http_client = lo_http_client.

* Set HTTP version
    lo_http_client->request->set_version( if_http_request=>co_protocol_version_1_0 ).
    if lo_http_client is bound and lo_rest_client is bound.

* Set the URI if any
      cl_http_utility=>set_request_uri(
        exporting
          request = lo_http_client->request    " HTTP Framework (iHTTP) HTTP Request
          uri     = iv_uri                     " URI String (in the Form of /path?query-string)
      ).

* HTTP GET
      lo_rest_client->if_rest_client~get( ).

* HTTP_POST

      data: lo_json        type ref to cl_clb_parse_json,
            lo_request     type ref to if_rest_entity,
            lo_sql         type ref to cx_sy_open_sql_db,
            status         type  string,
            reason         type  string,
            response       type  string,
            content_length type  string,
            location       type  string,
            content_type   type  string,
            lv_status      type  i.

* Set Payload or body ( JSON or XML)
      lo_request = lo_rest_client->if_rest_client~create_request_entity( ).
      lo_request->set_content_type( iv_media_type = if_rest_media_type=>gc_appl_json ).
      lo_request->set_string_data( iv_body ).

* Set request header if any
      call method lo_rest_client->if_rest_client~set_request_header
        exporting
          iv_name  = 'auth-token'
          iv_value = token. "Set your header .
* POST
      lo_rest_client->if_rest_resource~post( lo_request ).
* Collect response

* HTTP response
      lo_response = lo_rest_client->if_rest_client~get_response_entity( ).
* HTTP return status
      http_status = lv_status = lo_response->get_header_field( '~status_code' ).
      reason = lo_response->get_header_field( '~status_reason' ).
      content_length = lo_response->get_header_field( 'content-length' ).
      location = lo_response->get_header_field( 'location' ).
      content_type = lo_response->get_header_field( 'content-type' ).
* RAW response
      response = lo_response->get_string_data( ).
* JSON to ABAP
      data lr_json_deserializer type ref to cl_trex_json_deserializer.
      types: begin of ty_json_res,
               error   type string,
               details type string,
             end of ty_json_res.
      data: json_res type ty_json_res.

      ev_http_response_status_code = http_status.
      ev_http_response = response.

    endif.
  endmethod.


  method send_notification.

    data: lob_any            type ref to object,
          lc_container_t     type ref to if_swj_ppf_container,
          lc_exit_t          type ref to if_ex_exec_methodcall_ppf,
          lv_application_log type balloghndl,
          l_rp_status_t      type ppfdtstat,
          lv_partner_guid    type bu_partner_guid,
          lt_recepients      type aicrm_t_bupa,
          lc_dummy_partner_t type ref to cl_partner_ppf.

    rv_status = 2.
    lob_any = ca_doc_crm_order_h=>agent->if_os_ca_service~get_ref_by_oid(
      iv_rfc_guid ).
    "lcl_doc_crm_order_h ?= lob_any.

*                       create container
    create object lc_container_t type cl_swj_ppf_container.
    create object lc_dummy_partner_t.
*                       create PPF Exit
    call method cl_exithandler=>get_instance
      exporting
        exit_name              = 'EXEC_METHODCALL_PPF'
        null_instance_accepted = 'X'
      changing
        instance               = lc_exit_t.

* get receipents
    data(lt_suc_docs) = cl_hf_helper=>get_sucdocs_of_chng_doc( im_change_document_id = iv_rfc_guid ).
    refresh lt_recepients.
    loop at lt_suc_docs into data(lv_object_guid).
      call function 'SOCM_CRM_PA_GET_PARTNER'
        exporting
          iv_guid_crm     = lv_object_guid
          iv_partner_fct  = 'SMCD0001'
        importing
          ev_partner_guid = lv_partner_guid.

      check lv_partner_guid is not initial. "
      select single partner from but000 into @data(lv_partner) where partner_guid = @lv_partner_guid.
      append lv_partner to lt_recepients.
    endloop.

    sort lt_recepients.
    delete adjacent duplicates from lt_recepients.

    loop at lt_recepients into data(lv_recepient).
            lc_container_t->set_value( element_name = 'RECEIVER_BP'
                                       data = lv_recepient ).

            lc_container_t->set_value( element_name = if_aic_cm_email_service=>con_ppf_container_elements-mail_form_template
                                               data = 'TOO_CHARM_MAIL_TEMPLATE' ).

            lc_container_t->set_value( element_name = if_aic_cm_email_service=>con_ppf_container_elements-default_sender_email
                                       data = 'noreply@togg.com.tr' ).


            try.
                call method lc_exit_t->execute
                  exporting
                    flt_val            = 'SEND_MAIL_WITH_MAIL_FORMS'
                    io_appl_object     = lob_any
                    io_partner         = lc_dummy_partner_t
                    ip_application_log = lv_application_log
                    ip_preview         = space
                    ii_container       = lc_container_t
                    "ip_action          = 'SET_STATUS_BY_SUCDOC'
                  receiving
                    rp_status          = l_rp_status_t.            "no real PPF action
              catch cx_socm_condition_violated
                    cx_socm_declared_exception.

            endtry.

      endloop.
      rv_status = l_rp_status_t.

  endmethod.


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


  METHOD set_jira_status.
    DATA:
      lv_body        TYPE string,
      lv_uri         TYPE string,
      lv_stat_c      TYPE char4,
      lv_response    TYPE string,
      lv_http_status TYPE string,
      lv_jira_id     TYPE crmt_po_number_sold.

    SELECT SINGLE process_type FROM crmd_orderadm_h INTO @DATA(lv_p_type)
      WHERE guid = @iv_guid.

    CALL METHOD zcl_z_jira_charm_integration=>get_jira_id
      EXPORTING
        iv_guid    = iv_guid
      IMPORTING
        ev_jira_id = lv_jira_id.

    SELECT SINGLE jira_status FROM zjira_mapping INTO @DATA(lv_stat)
      WHERE process_type = @lv_p_type
      AND sm_status = @iv_status
      AND syst = @sy-sysid
      AND direction = 'O'.

    IF lv_jira_id IS NOT INITIAL.
      IF lv_stat IS NOT INITIAL.

          lv_stat_c = lv_stat.

          CONCATENATE
          '{"update":{"comment":[{"add":{"body":"'
          'Update from'
          sy-sysid
          '"}}]},"transition":{"id":'
           lv_stat_c
          '}}' INTO lv_body SEPARATED BY space.

          CONCATENATE lv_jira_id '/transitions' INTO lv_uri.

          CALL METHOD ZCL_Z_JIRA_CHARM_INTEGRATION=>post
            EXPORTING
              iv_body                      = lv_body
              iv_uri                       = lv_uri
            IMPORTING
              ev_http_response             = lv_response
              ev_http_response_status_code = lv_http_status.

          IF lv_response CS '{"errorMessages"'.
            es_error_message-msgty = 'E'.
            es_error_message-msgid = 'ZJIRA_INT'.
            es_error_message-msgno = '001'.
            es_error_message-msgv1 = lv_http_status.
            REPLACE ALL OCCURRENCES OF '{"errorMessages":["' IN lv_response WITH ''.
            es_error_message-msgv2 = lv_response.
            IF lv_response CS 'The likely cause is that somebody has changed the issue recently, please look at the issue'.
              es_error_message-msgv1 = 'STA'.
              CONCATENATE 'Status not valid for doc:' lv_jira_id INTO es_error_message-msgv2 SEPARATED BY space.
            ENDIF.
          ENDIF.
      ELSE.
*        "maintain mapping table zjira_mapping error
*        es_error_message-msgty = 'E'.
*        es_error_message-msgid = 'ZJIRA_INT'.
*        es_error_message-msgno = '000'.
*        es_error_message-msgv1 = lv_p_type.
*        es_error_message-msgv2 = iv_status.
      ENDIF.
    ENDIF.

  ENDMETHOD.


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


  METHOD set_status_by_job.
    DATA:
      lv_task_guid  TYPE sysuuid_x16,
      ls_selopt     TYPE rsparams,
      lt_selopt     TYPE rsparams_tt,
      lv_job_exists TYPE boolean,
      ls_balmi      TYPE balmi,
      lv_dummystr   TYPE string,
      lv_job_id     TYPE btcjobcnt.

    FIELD-SYMBOLS:
         <fs_task>       TYPE REF TO cl_td_task.

    CONSTANTS co_job_task_name TYPE char32 VALUE 'ZSET_CR_STATUS_TOBE_APPROVED'.
* check if there is a job currently running
    rv_success = abap_true.
    DATA(lt_task) = cl_td_task_manager=>get_all_open_tasks(
      iv_task_name = co_job_task_name ).
    IF lt_task IS NOT INITIAL.
      DO 5 TIMES.
        LOOP AT lt_task ASSIGNING <fs_task>.
          IF <fs_task>->get_status( ) = cl_td_task_manager=>con_task_status_in_progress. "'P'. " in progress
            lv_job_exists = abap_true.
            WAIT UP TO 5 SECONDS.
            CONTINUE.
          ELSE.
            lv_job_exists = abap_false.

          ENDIF.
        ENDLOOP.
      ENDDO.
    ENDIF.

    IF lv_job_exists = abap_true.
      rv_success = abap_false.
      RETURN.
      " add log message and exit ?
    ENDIF.

    TRY.
        lv_task_guid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        " Message: Internal error
        MESSAGE e298(ags_td) INTO lv_dummystr.
        ls_balmi = cl_td_assistant=>prepare_app_log( ).
        "append ls_balmi to ip_application_log.
        rv_success = abap_false.
        RETURN.
    ENDTRY.

    "parameters
    CLEAR ls_selopt.
    ls_selopt-selname = 'P_GUID'.
    ls_selopt-kind    = 'P'.
    ls_selopt-sign    = 'I'.
    ls_selopt-option  = 'EQ'.
    ls_selopt-low     = iv_order_guid.
    INSERT ls_selopt INTO TABLE lt_selopt.

* Create a new job with JOB_OPEN

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = co_job_task_name
      IMPORTING
        jobcount         = lv_job_id
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      rv_success = abap_false.
    ENDIF.

*------------------------------------------------------------------------------
* Connect one report to the job by SUBMIT


    SUBMIT (co_job_task_name) AND RETURN
                  WITH p_taskid = lv_task_guid
                  WITH SELECTION-TABLE lt_selopt
                  USER sy-uname
                  VIA JOB co_job_task_name
                  NUMBER lv_job_id.

    IF sy-subrc <> 0.
      rv_success = abap_false.
    ENDIF.

*------------------------------------------------------------------------------
* Close the job definition with JOB_CLOSE to release the job

    " Convert the date and time from "000..." to space, so that JOB_CLOSE
    " doesn't recognize them as specified
*****  IF ls_batch-sdlstrtdt IS INITIAL.
*****    ls_batch-sdlstrtdt = lc_space_dats.
*****    ls_batch-sdlstrttm = lc_space_tims.
*****  ENDIF.
*****  IF ls_batch-laststrtdt IS INITIAL.
*****    ls_batch-laststrtdt = lc_space_dats.
*****    ls_batch-laststrttm = lc_space_tims.
*****  ENDIF.
    " Note that if you go to the JOB_CLOSE function module, you can find the
    " detailed parameter documentation there
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_job_id
        jobname              = co_job_task_name
        strtimmed            = abap_true
*       sdlstrtdt            = ls_batch-sdlstrtdt
*       sdlstrttm            = ls_batch-sdlstrttm
*       prddays              = ls_batch-prddays
*       prdhours             = ls_batch-prdhours
*       prdmins              = ls_batch-prdmins
*       prdmonths            = ls_batch-prdmonths
*       prdweeks             = ls_batch-prdweeks
*       laststrtdt           = ls_batch-laststrtdt
*       laststrttm           = ls_batch-laststrttm
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.
    IF sy-subrc <> 0.
      rv_success = abap_false.
    ENDIF.
  ENDMETHOD.


  method SET_STATUS_BY_PPF.

    data: lv_context         type ref to cl_doc_context_crm_order,
          lo_appl_object     type ref to object,
          li_container       type ref to if_swj_ppf_container,
          lo_partner         type ref to cl_partner_ppf,
          l_protocol_handle  type balloghndl,
          rp_status          type ppfdtstat,
          lc_container       type ref to if_swj_ppf_container,
          lc_exit            type ref to if_ex_exec_methodcall_ppf,
          lt_objects_to_save type crmt_object_guid_tab,
          ls_objects_to_save like line of lt_objects_to_save,
          lv_upd_str         type string.


    call function 'CRM_ACTION_CONTEXT_CREATE'
      exporting
        iv_header_guid                 = iv_object_guid
        iv_object_guid                 = iv_object_guid
      importing
        ev_context                     = lv_context
      exceptions
        no_actionprofile_for_proc_type = 1
        no_actionprofile_for_item_type = 2
        order_read_failed              = 3
        others                         = 4.
    if sy-subrc <> 0.
    endif.

    lo_appl_object = lv_context->appl.

    call function 'CRM_ORDER_ENQUEUE'
      exporting
        iv_guid  = iv_object_guid
        iv_local = 'X'
      exceptions
        others   = 1.
    if sy-subrc <> 0.

    endif.

*       get exit instance
    lc_exit ?= cl_exithandler_manager_ppf=>get_exit_handler(
       ip_badi_definition_name = 'EXEC_METHODCALL_PPF' ).

*       call HF_SET_STATUS - Status modification
    create object lc_container
      type
      cl_swj_ppf_container.
    lc_container->set_value( element_name = 'USER_STATUS'
                             data = iv_estatus ).

    try.
        call method lc_exit->execute
          exporting
            flt_val            = 'HF_SET_STATUS'
            io_appl_object     = lo_appl_object
            io_partner         = lo_partner
            ip_application_log = l_protocol_handle
            ip_preview         = ' '
            ii_container       = lc_container
          receiving
            rp_status          = rv_exec_status.
      catch cx_socm_condition_violated.
    endtry.

*       Publish event
    call function 'CRM_EVENT_PUBLISH_OW'
      exporting
        iv_obj_name = 'STATUS'
        iv_guid_hi  = iv_object_guid
        iv_kind_hi  = 'A'
        iv_event    = 'SAVE'.

      refresh lt_objects_to_save.
      ls_objects_to_save =  iv_object_guid.
      append ls_objects_to_save to lt_objects_to_save.

     call function 'CRM_ORDER_SAVE'
        exporting
          it_objects_to_save = lt_objects_to_save
         iv_no_bdoc_send    = 'X'
       exceptions
         document_not_saved = 1
         others             = 2.

  endmethod.


  METHOD update_status.

    DATA lv_ppf_exec_stat TYPE ppfdtstat.

    IF iv_action_name_check IS NOT INITIAL.

      DATA(order) = NEW cl_ai_crm_cm_com_crm_order_cm(
         guid = iv_guid
         log  = NEW cl_ai_crm_cm_com_logger( )
       ).
      TRY.
          order->if_ai_crm_cm_com_crm_order_pro~get_action_by_pattern( iv_action_name_check ).
          DATA(lv_action_found) = abap_true.
        CATCH cx_ai_crm_cm_com_not_found.
          RETURN. " actiok not found - no execution
      ENDTRY.

    ENDIF.

    CALL METHOD zcl_z_jira_charm_integration=>set_status_by_ppf(
      EXPORTING
        iv_object_guid = iv_guid
        iv_estatus     = iv_estat
      RECEIVING
        rv_exec_status = lv_ppf_exec_stat
                         ).

    IF lv_ppf_exec_stat = 1. " success

      rs_attributes_resp-statusresp = 'S'.
      rs_attributes_resp-messageresp = 'Status of object succesfully updated'.

    ELSEIF  lv_ppf_exec_stat = 2. " not success

      rs_attributes_resp-statusresp = 'E'.
      rs_attributes_resp-messageresp = 'Update of the status was not completed with success yet'.

    ENDIF.


  ENDMETHOD.
ENDCLASS.
