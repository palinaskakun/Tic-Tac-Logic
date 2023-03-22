.data


    //
    // The Game cell data structure
    // This is the contents of a location in the array
    //
    .equ    cell_expected, 0
    .equ    cell_actual, 4
    .equ    cell_size, 8

    // The Game description data structure
    //
    .equ    game_rows, 0
    .equ    game_cols, 4
    .equ    game_array, 8
    .equ    game_size, 16
    num:    .asciz "  %d"
    num_1: .asciz " %d"
    row_num:  .asciz "  %d "
    print_ch:   .asciz "  %c"
    one: .asciz " "
    two: .asciz "  "
    newline:      .asciz "\n"
.text

.global create_game

//
// Create the game abstract data type
// void *create_game(int rows, int cols)
//
create_game:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!
	stp x21, x22, [sp, #-16]!
  mov w19, w0      // rows
  mov w20, w1      // cols  

  mov w0, #1 // 1 to allocate
  mov w1, #game_size //how large?
  bl calloc       // allocate

  // Set the data structure initial values
  //
  str w19,[x0,#game_rows]
  str w20,[x0,#game_cols]


  mov x21, x0      // game pointer
        
        //
        // Allocate the game array
        //
  mul w0,w19,w20        // row * cols
  mov w1,#cell_size   // Cell size
  bl calloc
                    
  str x0,[x21,#game_array]
                        
  mov x0,x21

create_game_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    
    
.global destroy_game
//
// void destroy_game(void *game)
// Destroy the game, freeing all memory
//
destroy_game:
    
  	stp x29, x30, [sp, #-16]!
  	stp x19, x20, [sp, #-16]!
    
    mov x19, x0
    ldr x0, [x0,#game_array]
    bl free
    
    mov x0,x19
    bl free

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    
    
.global get_rows

//
// Get the number of rows in the game
// int get_rows(void *game)
//
get_rows:
    ldr w0,[x0,#game_rows]
    ret

.global get_cols

//
// Get the number of columns in the game
// int get_cols(void *game)
//
get_cols:
    ldr w0,[x0,#game_cols]
    ret

.global display_game

//
// Display the game
//
display_game:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    
    
    mov x23, x0 // ptr
    ldr w21, [x0, #game_rows]// load num of rows
    ldr w22, [x0, #game_cols]   // load num of columns
    mov w19, #1 //row index
    mov w20, #0 //column ind 
    



    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


.global set_cell_actual

//
// int set_cell_actual(void *game, int row, int col, char ch);
// Returns: 1 if the answer value is correct
//
set_cell_actual:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!

  mov w20,w3

  bl game_index
  ldr w4,[x0,#cell_expected] // this loads cell expected in w4

  str w20,[x0,#cell_actual] // saving
  mov w0,#1 // if actual=expected this returns 1
  cmp w4, w20 // compare them
  beq set_cell_actual_done // done if equals

  mov w0,#0 // othewise return 0
    



set_cell_actual_done:
	ldp x19, x20, [sp], #16
	ldp x29, x30, [sp], #16
    ret

.global set_cell_expected

//
// void set_cell_expected(void *game, int row, int col, char ch);
//
set_cell_expected:
	stp x29, x30, [sp, #-16]!
	stp x19, x20, [sp, #-16]!
    
  mov w19, w3           // save ch in w19
  bl game_index

  str w19, [x0, #cell_expected]  // save ch into game

	ldp x19, x20, [sp], #16
	ldp x29, x30, [sp], #16
  ret



.global game_win

//
// int game_win(void *game)
// Returns true when the game is done/won
//
game_win:
  stp x29, x30, [sp, #-16]!
  stp x19, x20, [sp, #-16]!
  stp x21, x22, [sp, #-16]!
  stp x23, x24, [sp, #-16]!
  mov w19, #1 // row
  mov w20, #1 // column
  ldr w21, [x0, #game_rows] // num of rows
  ldr w22, [x0, #game_cols] // num of columns
  mov x23, x0 // save the pointer
g_w_loop_cond:
    cmp w19, w21 //compare row and num of rows
    ble g_w_loop // rows index less or equals to num of rowss
    mov w0, #1 // if passed the loop-> finished -> return 1
    b game_win_done

g_w_loop:
    mov x0, x23 //ptr
    mov w1, w19 //row
    mov w2, w20 //col
    bl game_index //calling game index 

    ldr w1, [x0, #cell_expected]  // w1 set to expected
    ldr w2, [x0, #cell_actual]    // w2 set to actual
    cmp w1, w2                    //compare expected and actual
    bne g_w_false        //if not equal go to g_w_false and ret 0
    
    
    
    
    
    add w20,w20,#1 //add 1 to column index      
    cmp w20, w22   // compare column ind and number of cols
    bgt g_w_row   // if > or = , set col to 1 and increase rowo 

    b g_w_loop  // go to loop

game_win_done:
    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x29, x30, [sp], #16
    ret
g_w_false:
  // return 0
  mov x0, #0
  b game_win_done
g_w_row:
  add w19,w19,#1 // increase row by 1
  mov w20,#1 // set column to 1
  b g_w_loop_cond

.global game_index
//
// int *game_index(void *game, int row, int col)
// Get the address of a row and column in the cells
//   
game_index:
	sub w2,w2, #1 //subtr 1 from column
  sub w1, w1,#1 // subtr 1 from row

  ldr w3, [x0,#game_cols] // this loads number of columns 
  mul w1, w1,w3 // row*num of columns
  add w1,w1,w2 // the previous expression + column

  // current expression row = row*num of colums+columns
  mov w2, #cell_size  
  mul w1,w1,w2 // multiply the expression by cell size
  ldr x4,[x0, #game_array] // load address of the array

  add x4, x4,w1, uxtw // add array address to complete the formula
  mov x0,x4
  ret
	
