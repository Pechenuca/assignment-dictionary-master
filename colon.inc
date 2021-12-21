%macro colon 2
	%ifid %2	
		%ifdef ptr_begin
			%2: dq ptr_begin
		%else
			%2: dq 0
		%endif
		%define ptr_begin %2
	%else
		%fatal "Incorrect value!"
	%endif
    %ifstr %1
		db %1, 0
	%else
		%fatal "Incorrect key!"
	%endif
%endmacro