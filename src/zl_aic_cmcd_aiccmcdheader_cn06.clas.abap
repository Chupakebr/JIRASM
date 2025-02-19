class ZL_AIC_CMCD_AICCMCDHEADER_CN06 definition
  public
  inheriting from CL_AIC_CMCD_AICCMCDHEADER_CN06
  create public .

public section.

  methods GET_I_PO_NUMBER_SOLD
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZL_AIC_CMCD_AICCMCDHEADER_CN06 IMPLEMENTATION.


  method get_i_po_number_sold.

    data lv_process_type type crmt_process_type.
    data lv_guid         type crmt_object_guid.
    data current type ref to if_bol_bo_property_access.

    call method super->get_i_po_number_sold
        exporting
          iterator    = iterator
        receiving
          rv_disabled = rv_disabled.

    try.

        if iterator is bound.
          current = iterator->get_current( ).
        else.
          current = collection_wrapper->get_current( ).
        endif.

        current->get_property_as_value(
          exporting
            iv_attr_name = 'PROCESS_TYPE'
          importing
            ev_result    = lv_process_type
        ).

         current->get_property_as_value(
          exporting
            iv_attr_name = 'GUID'
          importing
            ev_result    = lv_guid
        ).


      catch cx_root.
    endtry.
    if lv_process_type cp 'Z*' or lv_process_type cp 'Y*'.

      select single z~sm_action from zjira_mapping as z left join crmd_orderadm_h as h
        on z~process_type = 'USER' and h~created_by = z~sm_action
        where h~guid = @lv_guid into @data(lv_auto).

       if lv_auto is not initial.
          rv_disabled = abap_true.
        else.
          rv_disabled = abap_false.
       endif.

    endif.



  endmethod.
ENDCLASS.
