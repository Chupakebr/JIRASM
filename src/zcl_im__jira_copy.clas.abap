class ZCL_IM__JIRA_COPY definition
  public
  final
  create public .

public section.

  interfaces IF_EX_CRM_COPY_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__JIRA_COPY IMPLEMENTATION.


  method IF_EX_CRM_COPY_BADI~ACTIVITY_H.
*** Call Routine AIC0001
  CALL METHOD cl_im_ai_crm_copy_badi=>if_ex_crm_copy_badi~activity_h
    EXPORTING
      is_ref_activity_h     = is_ref_activity_h
      flt_val               = cl_im_ai_crm_copy_badi=>c_ai_crm_copy_routine
      is_orderadm_h         = is_orderadm_h
      is_ref_orderadm_h     = is_ref_orderadm_h
    CHANGING
      cs_activity_h         = cs_activity_h
      ct_inputs_field_names = ct_inputs_field_names.
  endmethod.


  method IF_EX_CRM_COPY_BADI~ACTIVITY_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~AC_ASSIGN.
  endmethod.


  method IF_EX_CRM_COPY_BADI~BILLING.
  endmethod.


  method IF_EX_CRM_COPY_BADI~BILLPLAN.
  endmethod.


  method IF_EX_CRM_COPY_BADI~CANCEL.
  endmethod.


  method IF_EX_CRM_COPY_BADI~CLA_H.
  endmethod.


  method IF_EX_CRM_COPY_BADI~COPY.
  endmethod.


  METHOD if_ex_crm_copy_badi~customer_h.
*** Call Routine AIC0001
    CALL METHOD cl_im_ai_crm_copy_badi=>if_ex_crm_copy_badi~customer_h
      EXPORTING
        is_orderadm_h        = is_orderadm_h
        is_ref_orderadm_h    = is_ref_orderadm_h
        is_ref_customer_h    = is_ref_customer_h
        flt_val              = cl_im_ai_crm_copy_badi=>c_ai_crm_copy_routine
      CHANGING
        cs_customer_h        = cs_customer_h
        ct_input_field_names = ct_input_field_names.

  ENDMETHOD.


  method IF_EX_CRM_COPY_BADI~CUSTOMER_I.
  endmethod.


  METHOD if_ex_crm_copy_badi~dates.
*** Call Routine AIC0001
    CALL METHOD cl_im_ai_crm_copy_badi=>if_ex_crm_copy_badi~dates
      EXPORTING
        flt_val           = cl_im_ai_crm_copy_badi=>c_ai_crm_copy_routine
        is_orderadm_h     = is_orderadm_h
        is_ref_orderadm_h = is_ref_orderadm_h
        is_orderadm_i     = is_orderadm_i
        is_ref_orderadm_i = is_ref_orderadm_i
        it_ref_dates      = it_ref_dates
      CHANGING
        ct_input_fields   = ct_input_fields
        cs_date           = cs_date.

  ENDMETHOD.


  method IF_EX_CRM_COPY_BADI~DOC_FLOW.
  endmethod.


  method IF_EX_CRM_COPY_BADI~EXT_REF.

*** Call Routine AIC0001
  CALL METHOD cl_im_ai_crm_copy_badi=>if_ex_crm_copy_badi~ext_ref
    EXPORTING
      flt_val           = cl_im_ai_crm_copy_badi=>c_ai_crm_copy_routine
      is_orderadm_h     = is_orderadm_h
      is_ref_orderadm_h = is_ref_orderadm_h
      is_orderadm_i     = is_orderadm_i
      is_ref_orderadm_i = is_ref_orderadm_i
      it_ref_ext_ref    = it_ref_ext_ref
    CHANGING
      ct_input_fields   = ct_input_fields
      ct_ext_ref        = ct_ext_ref.

  endmethod.


  method IF_EX_CRM_COPY_BADI~FINPROD_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~IPM_RCHAR.
  endmethod.


  method IF_EX_CRM_COPY_BADI~IPM_RCTRL_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~LEAD_H.
  endmethod.


  method IF_EX_CRM_COPY_BADI~OPPORT_H.
  endmethod.


  method IF_EX_CRM_COPY_BADI~OPPORT_I.
  endmethod.


  METHOD if_ex_crm_copy_badi~orderadm_h.
*** Call Routine AIC0001
    CALL METHOD cl_im_ai_crm_copy_badi=>if_ex_crm_copy_badi~orderadm_h
      EXPORTING
        iu_orderadm_h        = iu_orderadm_h
        is_ref_orderadm_h    = is_ref_orderadm_h
        flt_val              = cl_im_ai_crm_copy_badi=>c_ai_crm_copy_routine
      CHANGING
        cs_orderadm_h        = cs_orderadm_h
        ct_input_field_names = ct_input_field_names.

    IF is_ref_orderadm_h-process_type = 'ZSMJ'.
      cs_orderadm_h-/salm/ext_id = ''.
    ENDIF.

  ENDMETHOD.


  method IF_EX_CRM_COPY_BADI~ORDERADM_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~ORDPRP_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~ORGMAN.
  endmethod.


  method IF_EX_CRM_COPY_BADI~PAYPLAN.
  endmethod.


  method IF_EX_CRM_COPY_BADI~PRICING.
  endmethod.


  method IF_EX_CRM_COPY_BADI~PRICING_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~PRODUCT_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~REFOBJ.
*** Call Routine AIC0001
  CALL METHOD cl_im_ai_crm_copy_badi=>if_ex_crm_copy_badi~refobj
    EXPORTING
      flt_val           = cl_im_ai_crm_copy_badi=>c_ai_crm_copy_routine
      is_orderadm_h     = is_orderadm_h
      is_ref_orderadm_h = is_ref_orderadm_h
      is_orderadm_i     = is_orderadm_i
      is_ref_orderadm_i = is_ref_orderadm_i
      it_ref_refobj     = it_ref_refobj
    CHANGING
      ct_input_fields   = ct_input_fields
      cs_refobj         = cs_refobj.

  endmethod.


  method IF_EX_CRM_COPY_BADI~SALES.
  endmethod.


  method IF_EX_CRM_COPY_BADI~SCHEDLIN_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~SERVICEPLAN_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~SERVICE_H.
*** Call Routine AIC0001
  CALL METHOD cl_im_ai_crm_copy_badi=>if_ex_crm_copy_badi~service_h
    EXPORTING
      is_orderadm_h        = is_orderadm_h
      is_ref_orderadm_h    = is_ref_orderadm_h
      is_ref_service_h     = is_ref_service_h
      flt_val              = cl_im_ai_crm_copy_badi=>c_ai_crm_copy_routine
    CHANGING
      cs_service_h         = cs_service_h
      ct_input_field_names = ct_input_field_names.

  endmethod.


  method IF_EX_CRM_COPY_BADI~SERVICE_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~SHIPPING.
  endmethod.


  method IF_EX_CRM_COPY_BADI~SRV_REQ_H.
  endmethod.


  method IF_EX_CRM_COPY_BADI~SUBJECT.
  endmethod.


  method IF_EX_CRM_COPY_BADI~UBB_CR_I.
  endmethod.


  method IF_EX_CRM_COPY_BADI~UBB_CTR_I.
  endmethod.
ENDCLASS.
