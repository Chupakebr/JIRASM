class ZCL_IM__JIRA_STATUS definition
  public
  final
  create public .

public section.

  interfaces IF_EX_EVAL_SCHEDCOND_PPF .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__JIRA_STATUS IMPLEMENTATION.


  METHOD if_ex_eval_schedcond_ppf~evaluate_schedule_condition.
    DATA:
      lr_crm_order  TYPE REF TO cl_doc_crm_order,
      lv_guid       TYPE crmt_object_guid,
      lv_kind       TYPE crmt_object_kind,
      lv_status     TYPE crm_j_status,
      lt_status_wrk TYPE crmt_status_wrkt.

    INCLUDE crm_direct.

* init
    ep_rc = 4.
    CATCH SYSTEM-EXCEPTIONS move_cast_error = 4.
      lr_crm_order ?= io_context->appl.
    ENDCATCH.
    CHECK sy-subrc = 0.

* get kind and guid
    lv_guid = lr_crm_order->get_crm_obj_guid( ).
    lv_kind = lr_crm_order->get_crm_obj_kind( ).

* only for header level
    CHECK lv_kind EQ gc_object_kind-orderadm_h.

* read status table
    CALL FUNCTION 'CRM_STATUS_READ_OW'
      EXPORTING
        iv_guid        = lv_guid
        iv_only_active = 'X'
      IMPORTING
        et_status_wrk  = lt_status_wrk
      EXCEPTIONS
        not_found      = 1
        OTHERS         = 2.

    IF sy-subrc = 0.
*   get required status for change
      CALL METHOD ii_container->get_value
        EXPORTING
          element_name = 'STATUS'
        IMPORTING
          data         = lv_status.
      IF NOT lv_status IS INITIAL.
*     check whether set or not
        READ TABLE lt_status_wrk WITH KEY
          status     = lv_status
          active_old = 'X' TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          ep_rc = 0.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ep_rc = 0.
      SELECT SINGLE z~sm_action FROM zjira_mapping AS z LEFT JOIN crmd_orderadm_h AS h
        ON z~process_type = 'USER' AND h~created_by = z~sm_action
        WHERE h~guid = @lv_guid INTO @DATA(lv_auto).
      IF lv_auto IS NOT INITIAL .
        ep_rc = 4.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
