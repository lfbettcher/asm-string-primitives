# asm-string-primitives
Low-level I/O procedures

Program Description:

This MASM program implements and tests two procedures for signed integers which use string primitive instructions.

`ReadVal`: gets user input in the form of a string of digits and converts (using string primitives) the string of ascii digits 
to its numeric value representation (SDWORD), validating the user's input is a valid number and fits into a 32 bit register.
The value is stored in a memory variable (output parameter, by reference).

`WriteVal`: Converts a numeric SDWORD value to a string of ascii digits and prints the ascii representation of the SDWORD value to the output.

The test program in `main` uses `ReadVal` and `WriteVal` to:
1. Get 10 valid integers from the user.
2. Store these numeric values in an array
3. Display the integers, their sum, and their average.

Program Requirements:
1. User's numeric input must be read in as a string and converted to numeric form.
2. Display an error message and re-prompt user if the number contains non-digits (other than '+' or '-') or is too large for 32-bit registers.
3. Cannot use Irvine library procedures to read or write numbers (ReadInt, ReadDec, WriteInt, WriteDec).
4. Conversion routines must use `LODSB` and `STOSB` for dealing with strings.
5. All procecdure parameters must be passed on the runtime stack. Strings must be passed by reference.
6. Used registers must be saved and restored by the called procedures and macros.
7. The stack frame must be cleaned up by the called procedure.
8. Procedures (except `main`) must not reference data segment variables by name.
9. The program must use *Register Indirect* addressing for integer (SDWORD) array elements, and *Base+Offset* addressing for accessing parameters on the runtime stack.

Extra:
1. Number each line of user input and display a running subtotal of the user's valid numbers. These displays must use `WriteVal`.
2. (TODO) Implement and test procedures `ReadFloatVal` and `WriteFloatVal` for floating point values, using the FPU.
