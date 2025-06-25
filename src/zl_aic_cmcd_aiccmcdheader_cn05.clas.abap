class ZL_AIC_CMCD_AICCMCDHEADER_CN05 definition
  public
  inheriting from CL_AIC_CMCD_AICCMCDHEADER_CN05
  create public .

public section.

  methods GET_I_ZZURL
    importing
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
    returning
      value(RV_DISABLED) type STRING .
  methods GET_M_ZZURL
    importing
      !ATTRIBUTE_PATH type STRING
    returning
      value(METADATA) type ref to IF_BSP_METADATA_SIMPLE .
  methods GET_ZZURL
    importing
      !ATTRIBUTE_PATH type STRING
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
    returning
      value(VALUE) type STRING .
  methods SET_ZZURL
    importing
      !ATTRIBUTE_PATH type STRING
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
      !VALUE type STRING .
  methods GET_P_ZZURL
    importing
      !IV_PROPERTY type STRING
      !IV_INDEX type I optional
      !IV_DISPLAY_MODE type ABAP_BOOL default ABAP_FALSE
    returning
      value(RV_VALUE) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZL_AIC_CMCD_AICCMCDHEADER_CN05 IMPLEMENTATION.


  method GET_I_ZZURL.
    DATA: current TYPE REF TO if_bol_bo_property_access.

    rv_disabled = 'TRUE'.
    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.

  TRY.

        IF current->is_property_readonly(
                      'ZZURL' ) = abap_false. "#EC NOTEXT
          rv_disabled = 'FALSE'.
        ENDIF.

    CATCH cx_sy_ref_is_initial cx_sy_move_cast_error
          cx_crm_genil_model_error.
      RETURN.
  ENDTRY.



  endmethod.


  method GET_M_ZZURL.

  DATA: attr    TYPE ZDTEL000056.

  DATA: dref    TYPE REF TO data.

  GET REFERENCE OF attr INTO dref.

  metadata ?= if_bsp_model_binding~get_attribute_metadata(
       attribute_ref  = dref
       attribute_path = attribute_path
       name           = 'ZZURL'  "#EC NOTEXT
*      COMPONENT      =
       no_getter      = 1 ).


  endmethod.


method get_p_zzurl.

*****  CASE iv_property.
*****    WHEN if_bsp_wd_model_setter_getter=>fp_fieldtype.
*****      "rv_value = cl_bsp_dlc_view_descriptor=>field_type_input.
*****
*****    "WHEN IF_BSP_WD_MODEL_SETTER_GETTER=>...
*****      "...
*****  ENDCASE.

  data lv_guid       type crmt_object_guid.

  data lr_entity     type ref to cl_crm_bol_entity.
  data lv_url        type string.
  data current       type ref to if_bol_bo_property_access.
  data dref          type ref to data.
  data ls_customer   type crmt_customer_h_wrk.


  "CHECK iv_display_mode = abap_false.
  current = collection_wrapper->get_current( ).

  try.

      data: coll   type ref to if_bol_entity_col.
      data: entity type ref to cl_crm_bol_entity.

      entity ?= current.

      check entity is bound.
****      select single value from dnoc_usercfg into lv_url "#EC CI_NOFIRST
****           where field = 'YARA_SNOW_URL'.
      entity->get_property_as_value(
        exporting
          iv_attr_name =     'GUID'
        importing
          ev_result    = lv_guid
      ).

      call function 'CRM_CUSTOMER_H_READ_OW'
        exporting
          iv_guid               = lv_guid
        importing
          es_customer_h_wrk     = ls_customer
        exceptions
          header_does_not_exist = 1
          others                = 2.

      select single guid_set into @data(lv_crmdlink_guid) from crmd_link where guid_hi = @lv_guid and objtype_set = '11'.
      select single po_number_sold into @data(lv_jira_id) from crmd_sales where guid = @lv_crmdlink_guid.

      select single sm_action from zjira_mapping where process_type = 'URL' and syst = @sy-sysid into @lv_url.
      replace all occurrences of '<jira_id>' in lv_url with lv_jira_id.

      "lv_url = 'https://iadc-sandbox-328.atlassian.net/browse/' && lv_jira_id.

      "lv_url = ls_customer-zzurl.

    catch cx_root.
  endtry.

  case iv_property.
    when if_bsp_wd_model_setter_getter=>fp_fieldtype.
* -> field type: client click


      "lr_entity ?= get_bo_by_index( iv_index ).
      "lr_data = lr_entity->get_property( 'URL_TO_DISPLAY' ).
**      ASSIGN lv_url TO <fs_url>.
      if lv_url is not initial.
*       Link to DAM -> backend event
        if strlen( lv_url ) > 11 and
          lv_url(11) = 'javascript:'.
          rv_value = cl_bsp_dlc_view_descriptor=>field_type_event_link.
        else.
          rv_value = cl_bsp_dlc_view_descriptor=>field_type_link.
        endif.
      elseif lv_url is initial.
        rv_value = cl_bsp_dlc_view_descriptor=>field_type_event_link.
      else.
        rv_value = cl_bsp_dlc_view_descriptor=>field_type_text.
      endif.
    when if_bsp_wd_model_setter_getter=>fp_onclick.
* -> onClick
****      lr_entity ?= get_bo_by_index( iv_index ).
****      lr_data = lr_entity->get_property( 'URL_TO_DISPLAY' ).
****      ASSIGN lr_data->* TO <fs_url>.
*     Link to DAM -> backend event
      if strlen( lv_url ) > 11 and
        lv_url(11) = 'javascript:'.
        rv_value = cl_gs_cm_doclist_impl=>gc_event_dam_display.
      elseif lv_url is initial.
        rv_value = cl_gs_cm_doclist_impl=>gc_event_doc_display.
      else.
        rv_value = lv_url.
      endif.
    when if_bsp_wd_model_setter_getter=>fp_tooltip.
* -> Tooltip
**      lr_entity ?= get_bo_by_index( iv_index ).
**      lr_data = lr_entity->get_property( 'KW_RELATIVE_URL' ).
**      ASSIGN lr_data->* TO <fs_kw_relative_url>.
      rv_value = lv_url.
  endcase.


  case iv_property.
    when if_bsp_wd_model_setter_getter=>fp_fieldtype.
      "rv_value = cl_bsp_dlc_view_descriptor=>field_type_input.

      "WHEN IF_BSP_WD_MODEL_SETTER_GETTER=>...
      "...
  endcase.



endmethod.


  METHOD get_zzurl.

    DATA: current TYPE REF TO if_bol_bo_property_access.
    DATA: dref    TYPE REF TO data.

    DATA lv_guid       TYPE crmt_object_guid.

    DATA lr_entity     TYPE REF TO cl_crm_bol_entity.
    DATA lv_url        TYPE string.
    DATA ls_customer   TYPE crmt_customer_h_wrk.


    "CHECK iv_display_mode = abap_false.
    current = collection_wrapper->get_current( ).

    TRY.

        DATA: coll   TYPE REF TO if_bol_entity_col.
        DATA: entity TYPE REF TO cl_crm_bol_entity.

        entity ?= current.

        CHECK entity IS BOUND.
****      select single value from dnoc_usercfg into lv_url "#EC CI_NOFIRST
****           where field = 'YARA_SNOW_URL'.
        entity->get_property_as_value(
          EXPORTING
            iv_attr_name =     'GUID'
          IMPORTING
            ev_result    = lv_guid
        ).
        "lv_url = ls_customer-zzurl.

      CATCH cx_root.
    ENDTRY.
    IF lv_guid IS NOT INITIAL.

      SELECT SINGLE z~sm_action FROM zjira_mapping AS z LEFT JOIN crmd_orderadm_h AS h
        ON z~process_type = 'USER' AND h~created_by = z~sm_action
        WHERE h~guid = @lv_guid INTO @DATA(lv_auto).
      IF lv_auto IS NOT INITIAL .
        value = 'Click here to access Jira ticket'.
      ELSE.
        value = ''.
      ENDIF.
    ELSE.
      value = ''.
    ENDIF.
*******
*******
*******    value =
*******'BTCustomerH not bound'."#EC NOTEXT
*******
*******
*******    if iterator is bound.
*******      current = iterator->get_current( ).
*******    else.
*******      current = collection_wrapper->get_current( ).
*******    endif.
*******
*******
*******  TRY.
*******
*******    TRY.
*******        dref = current->get_property( 'ZZURL' ). "#EC NOTEXT
*******      CATCH cx_crm_cic_parameter_error.
*******    ENDTRY.
*******
*******    CATCH cx_sy_ref_is_initial cx_sy_move_cast_error
*******          cx_crm_genil_model_error.
*******      RETURN.
*******  ENDTRY.
*******
*******    IF dref IS NOT BOUND.
*******
*******      value = 'BTCustomerH/ZZURL not bound'."#EC NOTEXT
*******
*******      RETURN.
*******    ENDIF.
*******    TRY.
*******        value = if_bsp_model_util~convert_to_string( data_ref = dref
*******                                    attribute_path = attribute_path ).
*******      CATCH cx_bsp_conv_illegal_ref.
*******        FIELD-SYMBOLS: <l_data> type DATA.
*******        assign dref->* to <l_data>.
********       please implement here some BO specific handler coding
********       conversion of currency/quantity field failed caused by missing
********       unit relation
********       Coding sample:
********       provide currency, decimals, and reference type
********       value = cl_bsp_utility=>make_string(
********                          value = <l_data>
********                          reference_value = c_currency
********                          num_decimals = decimals
********                          reference_type = reference_type
********                          ).
*******          value = '-CURR/QUANT REF DATA MISSING-'.
*******      CATCH cx_root.
*******        value = '-CONVERSION FAILED-'.                  "#EC NOTEXT
*******    ENDTRY.


  ENDMETHOD.


  method SET_ZZURL.
    DATA:
      current TYPE REF TO if_bol_bo_property_access,
      dref    TYPE REF TO data,
      copy    TYPE REF TO data.

    FIELD-SYMBOLS:
      <nval> TYPE ANY,
      <oval> TYPE ANY.

*   get current entity
    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.

*   get old value and dataref to appropriate type

  TRY.

    TRY.
        dref = current->get_property( 'ZZURL' ). "#EC NOTEXT
      CATCH cx_crm_cic_parameter_error.
    ENDTRY.

    CATCH cx_sy_ref_is_initial cx_sy_move_cast_error
          cx_crm_genil_model_error.
      RETURN.
  ENDTRY.


*   assure that attribue exists
    CHECK dref IS BOUND.

*   set <oval> to old value
    ASSIGN dref->* TO <oval>.
*   create a copy for new value
    CREATE DATA copy LIKE <oval>.
*   set <nval> to new value
    ASSIGN copy->* TO <nval>.

*   fill new value using the right conversion
    TRY.
*        TRY.
        CALL METHOD if_bsp_model_util~convert_from_string
          EXPORTING
            data_ref       = copy
            value          = value
            attribute_path = attribute_path.
*        CATCH cx_bsp_conv_illegal_ref.
*          FIELD-SYMBOLS: <l_data> type DATA.
*          assign copy->* to <l_data>.
*         please implement here some BO specific handler coding
*         conversion of currency/quantity field failed caused by missing
*         unit relation
*         Coding sample:
*         provide currency for currency fields or decimals for quantity (select from T006).
*          cl_bsp_utility=>instantiate_simple_data(
*                             value = value
*                             reference = c_currency
*                             num_decimals = decimals
*                             use_bsp_exceptions = abap_true
*                             data = <l_data> ).
*      ENDTRY.
      CATCH cx_sy_conversion_error.
        RAISE EXCEPTION TYPE cx_bsp_conv_failed
          EXPORTING
            name = 'ZZURL'."#EC NOTEXT
    ENDTRY.

*   only set new value if value has changed
    IF <nval> <> <oval>.

      current->set_property(
                      iv_attr_name = 'ZZURL' "#EC NOTEXT
                      iv_value     = <nval> ).

    ENDIF.


  endmethod.
ENDCLASS.
