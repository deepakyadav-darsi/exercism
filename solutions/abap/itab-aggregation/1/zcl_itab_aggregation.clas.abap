CLASS zcl_itab_aggregation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    TYPES: BEGIN OF initial_numbers_type,
             group  TYPE string,
             number TYPE i,
           END OF initial_numbers_type,
           initial_numbers TYPE STANDARD TABLE OF initial_numbers_type WITH EMPTY KEY.

    TYPES: BEGIN OF aggregated_data_type,
             group   TYPE string,
             count   TYPE i,
             sum     TYPE i,
             min     TYPE i,
             max     TYPE i,
             average TYPE f,
           END OF aggregated_data_type,
           aggregated_data TYPE STANDARD TABLE OF aggregated_data_type WITH EMPTY KEY.

    METHODS perform_aggregation
      IMPORTING
        initial_numbers        TYPE initial_numbers
      RETURNING
        VALUE(aggregated_data) TYPE aggregated_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_itab_aggregation IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: lt_mock_input TYPE initial_numbers,
          lt_result     TYPE aggregated_data.

    " 1. Create mock data identical to the exercise prompt
    lt_mock_input = VALUE #(
      ( group = 'A' number = 10 )
      ( group = 'B' number = 5 )
      ( group = 'A' number = 6 )
      ( group = 'C' number = 22 )
      ( group = 'A' number = 13 )
      ( group = 'C' number = 500 )
    ).

    lt_result = perform_aggregation( initial_numbers = lt_mock_input ).

    out->write( '--- ORIGINAL INPUT DATA ---' ).
    out->write( lt_mock_input ).

    out->write( '--- AGGREGATED OUTPUT DATA ---' ).
    out->write( lt_result ).
  ENDMETHOD.


  METHOD perform_aggregation.
  
    FIELD-SYMBOLS: <ls_input>  LIKE LINE OF initial_numbers,
                   <ls_result> LIKE LINE OF aggregated_data.

    LOOP AT initial_numbers ASSIGNING <ls_input>.
      READ TABLE aggregated_data ASSIGNING <ls_result>
                 WITH KEY group = <ls_input>-group.

      IF sy-subrc <> 0.
        APPEND VALUE aggregated_data_type(
          group = <ls_input>-group
          count = 1
          sum   = <ls_input>-number
          min   = <ls_input>-number
          max   = <ls_input>-number
        ) TO aggregated_data ASSIGNING <ls_result>.
      ELSE.
        <ls_result>-count = <ls_result>-count + 1.
        <ls_result>-sum   = <ls_result>-sum + <ls_input>-number.

        IF <ls_input>-number < <ls_result>-min.
          <ls_result>-min = <ls_input>-number.
        ENDIF.

        IF <ls_input>-number > <ls_result>-max.
          <ls_result>-max = <ls_input>-number.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT aggregated_data ASSIGNING <ls_result>.
      <ls_result>-average = <ls_result>-sum / <ls_result>-count.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.