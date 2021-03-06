LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

ENTITY Processor is
    port( CLK, Register_RST, Buffer_RST, Interrupt: IN  STD_LOGIC;
          pport : INOUT STD_LOGIC_Vector(15 Downto 0) := (others => '0')
    );
END ENTITY;


ARCHITECTURE flow OF Processor IS

--------------------------------------------      SIGNALS      ----------------------------------------------
SIGNAL PC_Register_IN       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL PC_Register_OUT      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL PC_Adder_OUT         : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL SP_Register_IN       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL SP_Register_OUT      : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Flag_Register_IN     : STD_LOGIC_VECTOR( 2 DOWNTO 0) := (others => '0');
SIGNAL Flag_Register_OUT    : STD_LOGIC_VECTOR( 2 DOWNTO 0) := (others => '0');

SIGNAL Register0_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Register1_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Register2_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Register3_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Register4_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Register5_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Register6_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Register7_OUTPUT     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');

SIGNAL RST_FD_Buffer1        : STD_LOGIC := '0';
SIGNAL RST_FD_Buffer2        : STD_LOGIC := '0';
SIGNAL RST_DE_Buffer1        : STD_LOGIC := '0';
SIGNAL RST_DE_Buffer2        : STD_LOGIC := '0';
SIGNAL RST_EM_Buffer1        : STD_LOGIC := '0';
SIGNAL RST_EM_Buffer2        : STD_LOGIC := '0';
SIGNAL RST_MW_Buffer1        : STD_LOGIC := '0';
SIGNAL RST_MW_Buffer2        : STD_LOGIC := '0';

SIGNAL pc_reset_out          : STD_LOGIC_VECTOR(31 DOWNTO 0);

--------------------------------------------  FETCH TO BUFFER  ----------------------------------------------

signal IR1_Fetch_out, IR2_Fetch_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

--------------------------------------------------------------------------------------------------------------
--------------------------------------------    IF\ID Buffer    ----------------------------------------------

signal	IR1_FD_out, IR2_FD_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_FD_out, SP_FD_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_FD_out          		                                	    :  STD_LOGIC_VECTOR (2 DOWNTO 0);

---- For Channel 1 -> ALU 1
        
signal	NOP1_FD_out, Taken1_FD_out, SET_Carry1_FD_out, CLR_Carry1_FD_out,
        Two_Operand_Instr1_Flag_FD_out, One_or_Two1_FD_out                  : STD_LOGIC;
        
signal	ALU1_OP_Code_FD_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0); 
        
signal	ALU1_Operand1_FD_out, ALU1_Operand2_FD_out, ALU1_Result_FD_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);
                              
---- For Channel 2 -> ALU 2
        
signal	NOP2_FD_out ,Taken2_FD_out, SET_Carry2_FD_out, CLR_Carry2_FD_out,
        Two_Operand_Instr2_Flag_FD_out, One_or_Two2_FD_out                  : STD_LOGIC;

signal	ALU2_OP_Code_FD_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0);         
        
signal	ALU2_Operand1_FD_out, ALU2_Operand2_FD_out, ALU2_Result_FD_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);                    

---- For Channel 1

signal	Memory_Read1_FD_out, Memory_Write1_FD_out, ALU_As_Address1_FD_out,
        SP_As_Address1_FD_out, PC_As_Data1_FD_out       	                : STD_LOGIC;
        		
---- For Channel 2
	    
signal	Memory_Read2_FD_out, Memory_Write2_FD_out, ALU_As_Address2_FD_out,
        SP_As_Address2_FD_out, PC_As_Data2_FD_out 			                : STD_LOGIC;
        			
signal	Memory_Result_FD_out	        	                                : STD_LOGIC_VECTOR (31 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_FD_out, Rdst_Idx1_FD_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_FD_out, Enable_Reg1_FD_out, Mem_or_ALU1_FD_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_FD_out, Rdst_Idx2_FD_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_FD_out, Enable_Reg2_FD_out, Mem_or_ALU2_FD_out			: STD_LOGIC;             

SIGNAL memoryzero : STD_LOGIC_VECTOR(15 downto 0);
--------------------------------------------------------------------------------------------------------------     
--------------------------------------------   Decode TO Buffer  ----------------------------------------------

signal ALU_Forwarding1last1, First_op1last1, Second_op1last1, ALU_Forwarding1last2, First_op1last2, Second_op1last2 : STD_LOGIC; 
signal ALU_Forwarding1lastlast1, First_op1lastlast1, Second_op1lastlast1, ALU_Forwarding1lastlast2, First_op1lastlast2, Second_op1lastlast2 : STD_LOGIC; 
signal ALU_Forwarding2last1, First_op2last1, Second_op2last1,ALU_Forwarding2last2, First_op2last2, Second_op2last2 : STD_LOGIC;
signal ALU_Forwarding2lastlast1, First_op2lastlast1, Second_op2lastlast1,ALU_Forwarding2lastlast2, First_op2lastlast2, Second_op2lastlast2 : STD_LOGIC;

signal MemForward1last1,MemForward2last1,MemForward1last2,MemForward2last2 : STD_LOGIC;
signal FstOpMem1last1,FstOpMem1last2,ScndOpMem1last1,ScndOpMem1last2 : STD_LOGIC;
signal FstOpMem2last1,FstOpMem2last2,ScndOpMem2last1,ScndOpMem2last2 : STD_LOGIC;
---- For Channel 1 -> ALU 1
        
signal	NOP1_Decode_out, Taken1_Decode_out, SET_Carry1_Decode_out, CLR_Carry1_Decode_out,
        Two_Operand_Instr1_Flag_Decode_out, One_or_Two1_Decode_out          : STD_LOGIC;
        
signal	ALU1_OP_Code_Decode_out   			                                : STD_LOGIC_VECTOR  (2 DOWNTO 0); 
        
signal	ALU1_Operand1_Decode_out, ALU1_Operand2_Decode_out,
        ALU1_Result_Decode_out                                              : STD_LOGIC_VECTOR  (31 DOWNTO 0);
                              
---- For Channel 2 -> ALU 2
        
signal	NOP2_Decode_out ,Taken2_Decode_out, SET_Carry2_Decode_out, CLR_Carry2_Decode_out,
        Two_Operand_Instr2_Flag_Decode_out, One_or_Two2_Decode_out          : STD_LOGIC;

signal	ALU2_OP_Code_Decode_out   			                                : STD_LOGIC_VECTOR  (2 DOWNTO 0);         
        
signal	ALU2_Operand1_Decode_out, ALU2_Operand2_Decode_out,
        ALU2_Result_Decode_out                                              : STD_LOGIC_VECTOR  (31 DOWNTO 0);                    

---- For Channel 1

signal	Memory_Read1_Decode_out, Memory_Write1_Decode_out, ALU_As_Address1_Decode_out,
        SP_As_Address1_Decode_out, PC_As_Data1_Decode_out       	        : STD_LOGIC;
        		
---- For Channel 2
	    
signal	Memory_Read2_Decode_out, Memory_Write2_Decode_out, ALU_As_Address2_Decode_out,
        SP_As_Address2_Decode_out, PC_As_Data2_Decode_out 	                : STD_LOGIC;
        			
signal	Memory_Result_Decode_out	        	                            : STD_LOGIC_VECTOR (31 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_Decode_out, Rdst_Idx1_Decode_out                			: STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_Decode_out, Enable_Reg1_Decode_out,
        Mem_or_ALU1_Decode_out		                                        : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_Decode_out, Rdst_Idx2_Decode_out                			: STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_Decode_out, Enable_Reg2_Decode_out,
        Mem_or_ALU2_Decode_out			                                    : STD_LOGIC;             


--------------------------------------------------------------------------------------------------------------     
--------------------------------------------  ID\Ex Buffer  ----------------------------------------------


signal	ALU1_Operand1_E_in, ALU1_Operand2_E_in : STD_LOGIC_VECTOR(31 downto 0);
signal	ALU2_Operand1_E_in, ALU2_Operand2_E_in : STD_LOGIC_VECTOR(31 downto 0); 



signal	IR1_DE_out, IR2_DE_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_DE_out, SP_DE_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_DE_out          		                                	    :  STD_LOGIC_VECTOR (2 DOWNTO 0);

---- For Channel 1 -> ALU 1
        
signal	NOP1_DE_out, Taken1_DE_out, SET_Carry1_DE_out, CLR_Carry1_DE_out,
        Two_Operand_Instr1_Flag_DE_out, One_or_Two1_DE_out                  : STD_LOGIC;
        
signal	ALU1_OP_Code_DE_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0); 
        
signal	ALU1_Operand1_DE_out, ALU1_Operand2_DE_out, ALU1_Result_DE_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);
                              
---- For Channel 2 -> ALU 2
        
signal	NOP2_DE_out ,Taken2_DE_out, SET_Carry2_DE_out, CLR_Carry2_DE_out,
        Two_Operand_Instr2_Flag_DE_out, One_or_Two2_DE_out                  : STD_LOGIC;

signal	ALU2_OP_Code_DE_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0);         
        
signal	ALU2_Operand1_DE_out, ALU2_Operand2_DE_out, ALU2_Result_DE_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);                    

---- For Channel 1

signal	Memory_Read1_DE_out, Memory_Write1_DE_out, ALU_As_Address1_DE_out,
        SP_As_Address1_DE_out, PC_As_Data1_DE_out       	                : STD_LOGIC;
        		
---- For Channel 2
	    
signal	Memory_Read2_DE_out, Memory_Write2_DE_out, ALU_As_Address2_DE_out,
        SP_As_Address2_DE_out, PC_As_Data2_DE_out 			                : STD_LOGIC;
        			
signal	Memory_Result_DE_out	        	                                : STD_LOGIC_VECTOR (31 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_DE_out, Rdst_Idx1_DE_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_DE_out, Enable_Reg1_DE_out, Mem_or_ALU1_DE_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_DE_out, Rdst_Idx2_DE_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_DE_out, Enable_Reg2_DE_out, Mem_or_ALU2_DE_out			: STD_LOGIC;             


---------------------------------------------------------------------------------------------------------------     
--------------------------------------------  Execute to Buffer  ----------------------------------------------

signal ALU1_Execute_out, ALU2_Execute_out                                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal Taken1_Execute_out, Taken2_Execute_out                               : STD_LOGIC;
signal ALU1_Jump_DST, ALU2_Jump_DST                                         : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Flags_Execute_out		                                            : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others =>'0');

--------------------------------------------------------------------------------------------------------------     
--------------------------------------------  Ex\Mem Buffer  ----------------------------------------------

signal	IR1_EM_out, IR2_EM_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_EM_out, SP_EM_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_EM_out          		                                	    :  STD_LOGIC_VECTOR (2 DOWNTO 0);

---- For Channel 1 -> ALU 1
        
signal	NOP1_EM_out, Taken1_EM_out, SET_Carry1_EM_out, CLR_Carry1_EM_out,
        Two_Operand_Instr1_Flag_EM_out, One_or_Two1_EM_out                  : STD_LOGIC;
        
signal	ALU1_OP_Code_EM_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0); 
        
signal	ALU1_Operand1_EM_out, ALU1_Operand2_EM_out, ALU1_Result_EM_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);
                              
---- For Channel 2 -> ALU 2
        
signal	NOP2_EM_out ,Taken2_EM_out, SET_Carry2_EM_out, CLR_Carry2_EM_out,
        Two_Operand_Instr2_Flag_EM_out, One_or_Two2_EM_out                  : STD_LOGIC;

signal	ALU2_OP_Code_EM_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0);         
        
signal	ALU2_Operand1_EM_out, ALU2_Operand2_EM_out, ALU2_Result_EM_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);                    

---- For Channel 1

signal	Memory_Read1_EM_out, Memory_Write1_EM_out, ALU_As_Address1_EM_out,
        SP_As_Address1_EM_out, PC_As_Data1_EM_out       	                : STD_LOGIC;
        		
---- For Channel 2
	    
signal	Memory_Read2_EM_out, Memory_Write2_EM_out, ALU_As_Address2_EM_out,
        SP_As_Address2_EM_out, PC_As_Data2_EM_out 			                : STD_LOGIC;
        			
signal	Memory_Result_EM_out	        	                                : STD_LOGIC_VECTOR (31 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_EM_out, Rdst_Idx1_EM_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_EM_out, Enable_Reg1_EM_out, Mem_or_ALU1_EM_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_EM_out, Rdst_Idx2_EM_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_EM_out, Enable_Reg2_EM_out, Mem_or_ALU2_EM_out			: STD_LOGIC;             


---------------------------------------------------------------------------------------------------------------     
--------------------------------------------  Memory to Buffer  ----------------------------------------------

signal RET1_memory_out, RET2_memory_out                                     : STD_LOGIC;
signal Memory_Memory_out                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);


--------------------------------------------------------------------------------------------------------------     
--------------------------------------------    Mem\WB Buffer    ----------------------------------------------

signal	IR1_MW_out, IR2_MW_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_MW_out, SP_MW_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_MW_out          		                                	    :  STD_LOGIC_VECTOR (2 DOWNTO 0);

---- For Channel 1 -> ALU 1
        
signal	NOP1_MW_out, Taken1_MW_out, SET_Carry1_MW_out, CLR_Carry1_MW_out,
        Two_Operand_Instr1_Flag_MW_out, One_or_Two1_MW_out                  : STD_LOGIC;
        
signal	ALU1_OP_Code_MW_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0); 
        
signal	ALU1_Operand1_MW_out, ALU1_Operand2_MW_out, ALU1_Result_MW_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);
                              
---- For Channel 2 -> ALU 2
        
signal	NOP2_MW_out ,Taken2_MW_out, SET_Carry2_MW_out, CLR_Carry2_MW_out,
        Two_Operand_Instr2_Flag_MW_out, One_or_Two2_MW_out                  : STD_LOGIC;

signal	ALU2_OP_Code_MW_out   			                                    : STD_LOGIC_VECTOR  (2 DOWNTO 0);         

signal	ALU2_Operand1_MW_out, ALU2_Operand2_MW_out, ALU2_Result_MW_out      : STD_LOGIC_VECTOR  (31 DOWNTO 0);                    

---- For Channel 1

signal	Memory_Read1_MW_out, Memory_Write1_MW_out, ALU_As_Address1_MW_out,
        SP_As_Address1_MW_out, PC_As_Data1_MW_out       	                : STD_LOGIC;
        		
---- For Channel 2
	    
signal	Memory_Read2_MW_out, Memory_Write2_MW_out, ALU_As_Address2_MW_out,
        SP_As_Address2_MW_out, PC_As_Data2_MW_out 			                : STD_LOGIC;
        			
signal	Memory_Result_MW_out	        	                                : STD_LOGIC_VECTOR (31 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_MW_out, Rdst_Idx1_MW_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_MW_out, Enable_Reg1_MW_out, Mem_or_ALU1_MW_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_MW_out, Rdst_Idx2_MW_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_MW_out, Enable_Reg2_MW_out, Mem_or_ALU2_MW_out			: STD_LOGIC;             


---------------------------------------------------------------------------------------------------------------     
----------------------------------------  WriteBack to Register File  -------------------------------------------

signal SP_WB_out                                         			: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal Data1_WB_out, Data2_WB_out                                 	: std_logic_vector(15 downto 0);

signal index1_WB_out, index2_WB_out                               	: std_logic_vector(2 downto 0);

signal Write1_WB_out, Write2_WB_out                               	: std_logic;

SIGNAL Enable_SP                                                  	: STD_LOGIC := '0';



signal PC_Stall_out 													: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal IR1_Stall_out, IR2_Stall_out                                 	: STD_LOGIC_VECTOR(15 downto 0);

--------------------------------------------------------------------------------------------------------------
------------------------------------    E N D    O F    S I G N A L S   --------------------------------------
--------------------------------------------------------------------------------------------------------------

BEGIN

Enable_SP <= Enable_SP1_MW_out or Enable_SP2_MW_out;
PC_Register_IN <= "0000000000000000" & ALU1_Jump_DST when Taken1_Execute_out = '1'
                else "0000000000000000" & ALU2_Jump_DST when Taken2_Execute_out = '1'
                else Memory_Memory_out when RET1_memory_out = '1' or RET2_memory_out ='1'
                else PC_Stall_out;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Jumps Flush Logic
RST_DE_Buffer1 <= '1' when Taken1_Execute_out = '1' or Taken2_Execute_out = '1'
                or RET1_memory_out ='1' or RET2_memory_out = '1'
                else '0';
RST_DE_Buffer2 <= '1' when Taken1_Execute_out = '1' or Taken2_Execute_out = '1'
                or RET1_memory_out ='1' or RET2_memory_out = '1'
                else '0';

RST_EM_Buffer1 <= '1' when RET1_memory_out ='1' or RET2_memory_out = '1'
                else '0';
RST_EM_Buffer2 <= '1' when Taken1_Execute_out = '1'
                or RET1_memory_out ='1' or RET2_memory_out = '1'
                else '0';

RST_MW_Buffer2 <= '1' when RET1_memory_out = '1'
                else '0';
--===========================================================================
PC_Adder:-- For incrementing PC .. PC + 2 
ENTITY work.my_nadder
GENERIC MAP(n => 32)
PORT MAP(
	aa    => "00000000000000000000000000000010",
	bb    => PC_Register_OUT,
	c_cin => '0',
	ff    => PC_Adder_OUT
);	
--================ Global Registers ========================
Program_Counter_Register:
ENTITY work.Register_Falling
GENERIC MAP(n => 32)
PORT MAP(
	Reg_CLK  => CLK,
	Reg_RST  => Register_RST,
	RST_val  => pc_reset_out,
	EN       => '1',           
	Din      => PC_Register_IN,

	Dout     => PC_Register_OUT
);

Stack_Pointer_Register:
ENTITY work.Register_Falling
GENERIC MAP(n => 32)
PORT MAP(
	Reg_CLK  => CLK,
	Reg_RST  => Register_RST,
	RST_val  => "00000000000011111111111111111111",  -- 2**20 -1
	EN       => Enable_SP,
	Din      => SP_WB_out,

	Dout     => SP_Register_OUT
);

Flag_Register:
ENTITY work.Register_Falling
GENERIC MAP(n => 3)
PORT MAP(
	Reg_CLK  => CLK,
	Reg_RST  => Register_RST,
	RST_val  => (others => '0'),
	EN       => '1',          
	Din      => Flags_Execute_out,

	Dout     => Flag_Register_OUT
);
--=============================================================
--===================== Fetch Stage ===========================
--=============================================================

Fetch_Stage:
ENTITY work.Fetch
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        EXT_CLK           => CLK,
        EXT_INTR          => Interrupt,

        PC_IN             => PC_Register_OUT,
        IR1               => IR1_Fetch_out,
        IR2               => IR2_Fetch_out,
        memzero_OUT       => pc_reset_out
);

--=============================================================
IF_ID_Buffer:
ENTITY work.BUF
PORT MAP(
        EXT_CLK   => CLK,
        EXT_RST1  => RST_FD_Buffer1,
	EXT_RST2  => RST_FD_Buffer2,

	Stall     => '0',
        Flush     => '0',
-------------------------------------------------------
        IR1_IN    => IR1_Fetch_out,
        IR2_IN    => IR2_Fetch_out,
        PC_IN     => PC_Register_OUT,
        SP_IN     => SP_Register_OUT,
        Flags_IN  => Flag_Register_OUT,
-------------------------------------------------------

        NOP1_IN          => '0',
        Taken1_IN        => '0',
        SET_Carry1_IN    => '0',
        CLR_Carry1_IN    => '0',
        ALU1_OP_Code_IN  => "111",
        ALU1_Operand1_IN => (others => '0'),
        ALU1_Operand2_IN => (others => '0'),
        Two_Operand_Instr1_Flag_IN => '0',
        One_or_Two1_IN   => '0',
        ALU1_Result_IN   => (others => '0'),

----------------------------------------------------------

        NOP2_IN          => '0',
        Taken2_IN        => '0',
        SET_Carry2_IN    => '0',
        CLR_Carry2_IN    => '0',
        ALU2_OP_Code_IN  => "111",
        ALU2_Operand1_IN => (others => '0'),
        ALU2_Operand2_IN => (others => '0'),
        Two_Operand_Instr2_Flag_IN => '0',
        One_or_Two2_IN   => '0',
        ALU2_Result_IN   => (others => '0'),

-----------------------------------------------------------

        Memory_Read1_IN  => '0',
        Memory_Write1_IN => '0',
        ALU_As_Address1_IN => '0',
        SP_As_Address1_IN  => '0',
        PC_As_Data1_IN => '0',
-----------------------------------------------------------

        Memory_Read2_IN  => '0',
        Memory_Write2_IN => '0',
        ALU_As_Address2_IN => '0',
        SP_As_Address2_IN  => '0',
        PC_As_Data2_IN => '0',

        Memory_Result_IN => (others => '0'),
-----------------------------------------------------------

        Rsrc_Idx1_IN   => (others => '0'),
        Rdst_Idx1_IN   => (others => '0'),
        Enable_SP1_IN  => '0',
        Enable_Reg1_IN => '0',
        Mem_or_ALU1_IN => '0',
-----------------------------------------------------------

        Rsrc_Idx2_IN   => (others => '0'),
        Rdst_Idx2_IN   => (others => '0'),
        Enable_SP2_IN  => '0',
        Enable_Reg2_IN => '0',
        Mem_or_ALU2_IN => '0',
----------------------------------------------------------------
        IR1_OUT        => IR1_FD_out,
        IR2_OUT        => IR2_FD_out,
        PC_OUT         => PC_FD_out,   --- OLD PC
        SP_OUT         => SP_FD_out,   --- OLD SP
        Flags_OUT      => Flags_FD_out,

----------------------------------------------------------------
        NOP1_OUT                    => NOP1_FD_out,
        Taken1_OUT                  => Taken1_FD_out,
        SET_Carry1_OUT              => SET_Carry1_FD_out,
        CLR_Carry1_OUT              => CLR_Carry1_FD_out,
        ALU1_OP_Code_OUT            => ALU1_OP_Code_FD_out,
        ALU1_Operand1_OUT           => ALU1_Operand1_FD_out,
        ALU1_Operand2_OUT           => ALU1_Operand2_FD_out,
        Two_Operand_Instr1_Flag_OUT => Two_Operand_Instr1_Flag_FD_out,
        One_or_Two1_OUT             => One_or_Two1_FD_out,
        ALU1_Result_OUT             => ALU1_Result_FD_out,
-----------------------------------------------------------------
        NOP2_OUT                    => NOP2_FD_out,
        Taken2_OUT                  => Taken2_FD_out,
        SET_Carry2_OUT              => SET_Carry2_FD_out,
        CLR_Carry2_OUT              => CLR_Carry2_FD_out,
        ALU2_OP_Code_OUT            => ALU2_OP_Code_FD_out,
        ALU2_Operand1_OUT           => ALU2_Operand1_FD_out,
        ALU2_Operand2_OUT           => ALU2_Operand2_FD_out,
        Two_Operand_Instr2_Flag_OUT => Two_Operand_Instr2_Flag_FD_out,
        One_or_Two2_OUT             => One_or_Two2_FD_out,
        ALU2_Result_OUT             => ALU2_Result_FD_out,
------------------------------------------------------------------
        Memory_Read1_OUT       => Memory_Read1_FD_out,
        Memory_Write1_OUT      => Memory_Write1_FD_out,
        ALU_As_Address1_OUT    => ALU_As_Address1_FD_out,
        SP_As_Address1_OUT     => SP_As_Address1_FD_out,
        PC_As_Data1_OUT        => PC_As_Data1_FD_out,
------------------------------------------------------------------

        Memory_Read2_OUT       => Memory_Read2_FD_out,
        Memory_Write2_OUT      => Memory_Write2_FD_out,
        ALU_As_Address2_OUT    => ALU_As_Address2_FD_out,
        SP_As_Address2_OUT     => SP_As_Address2_FD_out,
        PC_As_Data2_OUT        => PC_As_Data2_FD_out,

        Memory_Result_OUT      => Memory_Result_FD_out,
-------------------------------------------------------------- --        

        Rsrc_Idx1_OUT        => Rsrc_Idx1_FD_out,
        Rdst_Idx1_OUT        => Rdst_Idx1_FD_out,
        Enable_SP1_OUT       => Enable_SP1_FD_out,
        Enable_Reg1_OUT      => Enable_Reg1_FD_out,
        Mem_or_ALU1_OUT      => Mem_or_ALU1_FD_out,
-----------------------------------------------------------------

        Rsrc_Idx2_OUT        => Rsrc_Idx2_FD_out,
        Rdst_Idx2_OUT        => Rdst_Idx2_FD_out,
        Enable_SP2_OUT       => Enable_SP2_FD_out,
        Enable_Reg2_OUT      => Enable_Reg2_FD_out,
        Mem_or_ALU2_OUT      => Mem_or_ALU2_FD_out
);

--=============================================================
--===================== Decode Stage ==========================
--=============================================================

STALL_UNIT:
ENTITY work.stall
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR1_CURR        => IR1_FD_out,
        IR1_PREV        => IR1_DE_out,    
        IR2_CURR        => IR2_FD_out,
        IR2_PREV        => IR2_DE_out,
        PC_IN           => PC_Register_OUT,         
        IR1_OUT         => IR1_Stall_out,
        IR2_OUT         => IR2_Stall_out,
        PC_OUT          => PC_Stall_out
);


Decode_Stage:
ENTITY work.Decode
GENERIC MAP(n => 16, m => 10)
PORT MAP(
            EXT_CLK                             => CLK,
            IR1_IN                              => IR1_Stall_out,
            IR2_IN                              => IR2_Stall_out,
            IN_PORT                             => pport,
            PC_IN             	                => PC_FD_out,
            SP_IN             			=> SP_FD_out,
            Flag_Register                       => Flags_FD_out,
            Reg0                                => Register0_OUTPUT,
            Reg1                                => Register1_OUTPUT,
            Reg2                                => Register2_OUTPUT,
            Reg3                                => Register3_OUTPUT,
            Reg4                                => Register4_OUTPUT,
            Reg5                                => Register5_OUTPUT,
            Reg6                                => Register6_OUTPUT,
            Reg7                                => Register7_OUTPUT,

--------------------------------------------------------------------------------------

            NOP1_OUT                            => NOP1_Decode_out,
            Taken1_OUT			        => Taken1_Decode_out,                        
            ALU1_OP_Code_OUT                    => ALU1_OP_Code_Decode_out,           
            ALU1_Operand1_OUT                   => ALU1_Operand1_Decode_out,  
            ALU1_Operand2_OUT                   => ALU1_Operand2_Decode_out,  
            Two_Operand_Instr1_Flag_OUT         => Two_Operand_Instr1_Flag_Decode_out,                             
            One_or_Two1_OUT                     => One_or_Two1_Decode_out,                     
            SETC1                               => SET_Carry1_Decode_out,
            CLRC1                               => CLR_Carry1_Decode_out,  

--------------------------------------------------------------------------------------

            NOP2_OUT                            => NOP2_Decode_out,
            Taken2_OUT			        => Taken2_Decode_out,                        
            ALU2_OP_Code_OUT                    => ALU2_OP_Code_Decode_out,           
            ALU2_Operand1_OUT                   => ALU2_Operand1_Decode_out,  
            ALU2_Operand2_OUT                   => ALU2_Operand2_Decode_out,  
            Two_Operand_Instr2_Flag_OUT         => Two_Operand_Instr2_Flag_Decode_out,                             
            One_or_Two2_OUT                     => One_or_Two2_Decode_out,                     
            SETC2                               => SET_Carry2_Decode_out,
            CLRC2                               => CLR_Carry2_Decode_out,
--------------------------------------------------------------------------------------

            Memory_Read1_OUT	                => Memory_Read1_Decode_out,  
            Memory_Write1_OUT			=> Memory_Write1_Decode_out,  
            ALU_As_Address1_OUT	                => ALU_As_Address1_Decode_out,                                
            SP_As_Address1_OUT		    	=> SP_As_Address1_Decode_out,                                
            PC_As_Data1_OUT		        => PC_As_Data1_Decode_out,  			
    
--------------------------------------------------------------------------------------

            Memory_Read2_OUT	                => Memory_Read2_Decode_out,  
            Memory_Write2_OUT			=> Memory_Write2_Decode_out,  
            ALU_As_Address2_OUT	                => ALU_As_Address2_Decode_out,                                
            SP_As_Address2_OUT		    	=> SP_As_Address2_Decode_out,                                
            PC_As_Data2_OUT		        => PC_As_Data2_Decode_out,  			               
    
            Memory_Result_OUT	        	=> Memory_Result_Decode_out,  
    
--------------------------------------------------------------------------------------

            Rsrc_Idx1_OUT	          	   => Rsrc_Idx1_Decode_out,  
            Rdst_Idx1_OUT	                   => Rdst_Idx1_Decode_out,  
            Enable_SP1_OUT			   => Enable_SP1_Decode_out,                                
            Enable_Reg1_OUT	                   => Enable_Reg1_Decode_out,  			               
            Mem_or_ALU1_OUT			   => Mem_or_ALU1_Decode_out,                                
        
--------------------------------------------------------------------------------------

            Rsrc_Idx2_OUT	          	   => Rsrc_Idx2_Decode_out,  
            Rdst_Idx2_OUT	                   => Rdst_Idx2_Decode_out,  
            Enable_SP2_OUT			   => Enable_SP2_Decode_out,                                
            Enable_Reg2_OUT	                   => Enable_Reg2_Decode_out,  			               
            Mem_or_ALU2_OUT			   => Mem_or_ALU2_Decode_out
    
);




--===============================================================
--============================  DE Buffer =======================
--===============================================================

ID_Exe_Buffer:
ENTITY work.BUF
PORT MAP(
        EXT_CLK   => CLK,
        EXT_RST1  => RST_DE_Buffer1,
	EXT_RST2  => RST_DE_Buffer2,

	Stall     => '0',
        Flush     => '0',
-------------------------------------------------------
        IR1_IN    => IR1_Stall_out,           -- OLD Registers ***********
        IR2_IN    => IR2_Stall_out,
        PC_IN     => PC_FD_out,
        SP_IN     => SP_FD_out,
        Flags_IN  => Flag_Register_OUT,
-------------------------------------------------------

        NOP1_IN          => NOP1_Decode_out,
        Taken1_IN        => Taken1_Decode_out,
        SET_Carry1_IN    => SET_Carry1_Decode_out,
        CLR_Carry1_IN    => CLR_Carry1_Decode_out,
        ALU1_OP_Code_IN  => ALU1_OP_Code_Decode_out,
        ALU1_Operand1_IN => ALU1_Operand1_Decode_out,
        ALU1_Operand2_IN => ALU1_Operand2_Decode_out,
        Two_Operand_Instr1_Flag_IN => Two_Operand_Instr1_Flag_Decode_out,
        One_or_Two1_IN   => One_or_Two1_Decode_out,
        ALU1_Result_IN   => ALU1_Result_FD_out,

----------------------------------------------------------

        NOP2_IN          => NOP2_Decode_out,
        Taken2_IN        => Taken2_Decode_out,
        SET_Carry2_IN    => SET_Carry2_Decode_out,
        CLR_Carry2_IN    => CLR_Carry2_Decode_out,
        ALU2_OP_Code_IN  => ALU2_OP_Code_Decode_out,
        ALU2_Operand1_IN => ALU2_Operand1_Decode_out,
        ALU2_Operand2_IN => ALU2_Operand2_Decode_out,
        Two_Operand_Instr2_Flag_IN => Two_Operand_Instr2_Flag_Decode_out,
        One_or_Two2_IN   => One_or_Two2_Decode_out,
        ALU2_Result_IN   => ALU2_Result_FD_out,

-----------------------------------------------------------

        Memory_Read1_IN  => Memory_Read1_Decode_out,
        Memory_Write1_IN => Memory_Write1_Decode_out,
        ALU_As_Address1_IN => ALU_As_Address1_Decode_out,
        SP_As_Address1_IN  => SP_As_Address1_Decode_out,
        PC_As_Data1_IN => PC_As_Data1_Decode_out,

-----------------------------------------------------------

        Memory_Read2_IN  => Memory_Read2_Decode_out,
        Memory_Write2_IN => Memory_Write2_Decode_out,
        ALU_As_Address2_IN => ALU_As_Address2_Decode_out,
        SP_As_Address2_IN  => SP_As_Address2_Decode_out,
        PC_As_Data2_IN => PC_As_Data2_Decode_out,

        Memory_Result_IN => (others => '0'),
-----------------------------------------------------------

        Rsrc_Idx1_IN   => Rsrc_Idx1_Decode_out,
        Rdst_Idx1_IN   => Rdst_Idx1_Decode_out,
        Enable_SP1_IN  => Enable_SP1_Decode_out,
        Enable_Reg1_IN => Enable_Reg1_Decode_out,
        Mem_or_ALU1_IN => Mem_or_ALU1_Decode_out,

-----------------------------------------------------------

        Rsrc_Idx2_IN   => Rsrc_Idx2_Decode_out,
        Rdst_Idx2_IN   => Rdst_Idx2_Decode_out,
        Enable_SP2_IN  => Enable_SP2_Decode_out,
        Enable_Reg2_IN => Enable_Reg2_Decode_out,
        Mem_or_ALU2_IN => Mem_or_ALU2_Decode_out,

----------------------------------------------------------------
        IR1_OUT        => IR1_DE_out,
        IR2_OUT        => IR2_DE_out,
        PC_OUT         => PC_DE_out,   --- OLD PC
        SP_OUT         => SP_DE_out,   --- OLD SP
        Flags_OUT      => Flags_DE_out,

----------------------------------------------------------------
        NOP1_OUT                    => NOP1_DE_out,
        Taken1_OUT                  => Taken1_DE_out,
        SET_Carry1_OUT              => SET_Carry1_DE_out,
        CLR_Carry1_OUT              => CLR_Carry1_DE_out,
        ALU1_OP_Code_OUT            => ALU1_OP_Code_DE_out,
        ALU1_Operand1_OUT           => ALU1_Operand1_DE_out,
        ALU1_Operand2_OUT           => ALU1_Operand2_DE_out,
        Two_Operand_Instr1_Flag_OUT => Two_Operand_Instr1_Flag_DE_out,
        One_or_Two1_OUT             => One_or_Two1_DE_out,
        ALU1_Result_OUT             => ALU1_Result_DE_out,
-----------------------------------------------------------------
        NOP2_OUT                    => NOP2_DE_out,
        Taken2_OUT                  => Taken2_DE_out,
        SET_Carry2_OUT              => SET_Carry2_DE_out,
        CLR_Carry2_OUT              => CLR_Carry2_DE_out,
        ALU2_OP_Code_OUT            => ALU2_OP_Code_DE_out,
        ALU2_Operand1_OUT           => ALU2_Operand1_DE_out,
        ALU2_Operand2_OUT           => ALU2_Operand2_DE_out,
        Two_Operand_Instr2_Flag_OUT => Two_Operand_Instr2_Flag_DE_out,
        One_or_Two2_OUT             => One_or_Two2_DE_out,
        ALU2_Result_OUT             => ALU2_Result_DE_out,
------------------------------------------------------------------
        Memory_Read1_OUT       => Memory_Read1_DE_out,
        Memory_Write1_OUT      => Memory_Write1_DE_out,
        ALU_As_Address1_OUT    => ALU_As_Address1_DE_out,
        SP_As_Address1_OUT     => SP_As_Address1_DE_out,
        PC_As_Data1_OUT        => PC_As_Data1_DE_out,
------------------------------------------------------------------

        Memory_Read2_OUT       => Memory_Read2_DE_out,
        Memory_Write2_OUT      => Memory_Write2_DE_out,
        ALU_As_Address2_OUT    => ALU_As_Address2_DE_out,
        SP_As_Address2_OUT     => SP_As_Address2_DE_out,
        PC_As_Data2_OUT        => PC_As_Data2_DE_out,

        Memory_Result_OUT      => Memory_Result_DE_out,
-------------------------------------------------------------- --        

        Rsrc_Idx1_OUT        => Rsrc_Idx1_DE_out,
        Rdst_Idx1_OUT        => Rdst_Idx1_DE_out,
        Enable_SP1_OUT       => Enable_SP1_DE_out,
        Enable_Reg1_OUT      => Enable_Reg1_DE_out,
        Mem_or_ALU1_OUT      => Mem_or_ALU1_DE_out,
-----------------------------------------------------------------

        Rsrc_Idx2_OUT        => Rsrc_Idx2_DE_out,
        Rdst_Idx2_OUT        => Rdst_Idx2_DE_out,
        Enable_SP2_OUT       => Enable_SP2_DE_out,
        Enable_Reg2_OUT      => Enable_Reg2_DE_out,
        Mem_or_ALU2_OUT      => Mem_or_ALU2_DE_out
);

--First DataForwarding Component
DataForwarding1last1:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR1_EM_out,
        IR_crnt         => IR1_DE_out,         
        Rdst_last       => Rdst_Idx1_EM_out,
        Rsrc_crnt       => Rsrc_Idx1_DE_out,
        Rdst_crnt       => Rdst_Idx1_DE_out,
        ALU_Forward     => ALU_Forwarding1last1,
        FirstOperand    => First_op1last1,
        SecondOperand   => Second_op1last1
);

DataForwarding1last2:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR2_EM_out,
        IR_crnt         => IR1_DE_out,         
        Rdst_last       => Rdst_Idx2_EM_out,
        Rsrc_crnt       => Rsrc_Idx1_DE_out,
        Rdst_crnt       => Rdst_Idx1_DE_out,
        ALU_Forward     => ALU_Forwarding1last2,
        FirstOperand    => First_op1last2,
        SecondOperand   => Second_op1last2
);

DataForwarding1lastlast1:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR1_MW_out,
        IR_crnt         => IR1_DE_out,         
        Rdst_last       => Rdst_Idx1_MW_out,
        Rsrc_crnt       => Rsrc_Idx1_DE_out,
        Rdst_crnt       => Rdst_Idx1_DE_out,
        ALU_Forward     => ALU_Forwarding1lastlast1,
        FirstOperand    => First_op1lastlast1,
        SecondOperand   => Second_op1lastlast1
);

DataForwarding1lastlast2:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR2_MW_out,
        IR_crnt         => IR1_DE_out,         
        Rdst_last       => Rdst_Idx2_MW_out,
        Rsrc_crnt       => Rsrc_Idx1_DE_out,
        Rdst_crnt       => Rdst_Idx1_DE_out,
        ALU_Forward     => ALU_Forwarding1lastlast2,
        FirstOperand    => First_op1lastlast2,
        SecondOperand   => Second_op1lastlast2
);

MemFwd1Last1:
ENTITY work.Mem_Forwd
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last             => IR1_MW_out,
        IR_crnt             => IR1_DE_out,    
        Rdst_last       => Rdst_Idx1_MW_out,
        Rsrc_crnt       => Rsrc_Idx1_DE_out,
        Rdst_crnt       => Rdst_Idx1_DE_out,
        Mem_Forward  => MemForward1last1,
        FirstOperand    => FstOpMem1last1,
        SecondOperand   => ScndOpMem1last1
);

MemFwd1last2:
ENTITY work.Mem_Forwd
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last             => IR2_MW_out,
        IR_crnt             => IR1_DE_out,    
        Rdst_last       => Rdst_Idx2_MW_out,
        Rsrc_crnt       => Rsrc_Idx1_DE_out,
        Rdst_crnt       => Rdst_Idx1_DE_out,         
        Mem_Forward  => MemForward1last2,
        FirstOperand    => FstOpMem1last2,
        SecondOperand   => ScndOpMem1last2
);

ALU1_Operand1_E_in <= ALU2_Result_EM_out when (First_op1last2='1' and ALU_Forwarding1last2='1')
else ALU1_Result_EM_out when (First_op1last1='1' and ALU_Forwarding1last1='1') 
else ALU2_Result_MW_out when (First_op1lastlast2='1' and ALU_Forwarding1lastlast2='1')
else ALU1_Result_MW_out when (First_op1lastlast1='1' and ALU_Forwarding1lastlast1='1')
else "0000000000000000" & Memory_Result_MW_out(31 downto 16) when ((FstOpMem1last1='1' and MemForward1last1='1') or (FstOpMem1last2='1' and MemForward1last2='1'))
else ALU1_Operand1_DE_out;

ALU1_Operand2_E_in <= ALU2_Result_EM_out when (Second_op1last2='1' and ALU_Forwarding1last2='1')
else ALU1_Result_EM_out when (Second_op1last1='1' and ALU_Forwarding1last1='1') 
else ALU2_Result_MW_out when (Second_op1lastlast2='1' and ALU_Forwarding1lastlast2='1')
else ALU1_Result_MW_out when (Second_op1lastlast1='1' and ALU_Forwarding1lastlast1='1')
else "0000000000000000" & Memory_Result_MW_out(31 downto 16) when ((ScndOpMem1last1='1' and MemForward1last1='1') or (ScndOpMem1last2='1' and MemForward1last2='1'))
else ALU1_Operand2_DE_out;


--Second DataForwarding Component
DataForwarding2last1:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR1_EM_out,
        IR_crnt         => IR2_DE_out,         
        Rdst_last       => Rdst_Idx1_EM_out,
        Rsrc_crnt       => Rsrc_Idx2_DE_out,
        Rdst_crnt       => Rdst_Idx2_DE_out,
        ALU_Forward     => ALU_Forwarding2last1,
        FirstOperand    => First_op2last1,
        SecondOperand   => Second_op2last1
);

DataForwarding2last2:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR2_EM_out,
        IR_crnt         => IR2_DE_out,         
        Rdst_last       => Rdst_Idx2_EM_out,
        Rsrc_crnt       => Rsrc_Idx2_DE_out,
        Rdst_crnt       => Rdst_Idx2_DE_out,
        ALU_Forward     => ALU_Forwarding2last2,
        FirstOperand    => First_op2last2,
        SecondOperand   => Second_op2last2
);

DataForwarding2lastlast1:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR1_MW_out,
        IR_crnt         => IR2_DE_out,         
        Rdst_last       => Rdst_Idx1_MW_out,
        Rsrc_crnt       => Rsrc_Idx2_DE_out,
        Rdst_crnt       => Rdst_Idx2_DE_out,
        ALU_Forward     => ALU_Forwarding2lastlast1,
        FirstOperand    => First_op2lastlast1,
        SecondOperand   => Second_op2lastlast1
);

DataForwarding2lastlast2:
ENTITY work.DataForwarding
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last         => IR2_MW_out,
        IR_crnt         => IR2_DE_out,         
        Rdst_last       => Rdst_Idx2_MW_out,
        Rsrc_crnt       => Rsrc_Idx2_DE_out,
        Rdst_crnt       => Rdst_Idx2_DE_out,
        ALU_Forward     => ALU_Forwarding2lastlast2,
        FirstOperand    => First_op2lastlast2,
        SecondOperand   => Second_op2lastlast2
);

MemFwd2Last1:
ENTITY work.Mem_Forwd
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last             => IR1_MW_out,
        IR_crnt             => IR2_DE_out,    
        Rdst_last       => Rdst_Idx1_MW_out,
        Rsrc_crnt       => Rsrc_Idx2_DE_out,
        Rdst_crnt       => Rdst_Idx2_DE_out,
        Mem_Forward  => MemForward2last1,
        FirstOperand    => FstOpMem2last1,
        SecondOperand   => ScndOpMem2last1
);

MemFwd2last2:
ENTITY work.Mem_Forwd
GENERIC MAP(n => 16, m => 10)
PORT MAP(
        IR_last             => IR2_MW_out,
        IR_crnt             => IR1_DE_out,    
        Rdst_last       => Rdst_Idx2_MW_out,
        Rsrc_crnt       => Rsrc_Idx2_DE_out,
        Rdst_crnt       => Rdst_Idx2_DE_out,         
        Mem_Forward  => MemForward2last2,
        FirstOperand    => FstOpMem2last2,
        SecondOperand   => ScndOpMem2last2
);


ALU2_Operand1_E_in <= ALU2_Result_EM_out when (First_op2last2='1' and ALU_Forwarding2last2='1')
else ALU1_Result_EM_out when (First_op2last1='1' and ALU_Forwarding2last1='1')
else ALU2_Result_MW_out when (First_op2lastlast2='1' and ALU_Forwarding2lastlast2='1')
else ALU1_Result_MW_out when (First_op2lastlast1='1' and ALU_Forwarding2lastlast1='1')
else "0000000000000000" & Memory_Result_MW_out(31 downto 16) when ((FstOpMem2last1='1' and MemForward2last1='1') or (FstOpMem2last2='1' and MemForward2last2='1'))
else ALU2_Operand1_DE_out;

ALU2_Operand2_E_in <= ALU2_Result_EM_out when (Second_op2last2='1' and ALU_Forwarding2last2='1')
else ALU1_Result_EM_out when (Second_op2last1='1' and ALU_Forwarding2last1='1')
else ALU2_Result_MW_out when (Second_op2lastlast2='1' and ALU_Forwarding2lastlast2='1')
else ALU1_Result_MW_out when (Second_op2lastlast1='1' and ALU_Forwarding2lastlast1='1')
else "0000000000000000" & Memory_Result_MW_out(31 downto 16) when ((ScndOpMem2last1='1' and MemForward2last1='1') or (ScndOpMem2last2='1' and MemForward2last2='1'))
else ALU2_Operand2_DE_out;


--=============================================================
--===================== Execution Stage ==========================
--=============================================================

Execution_Stage:
ENTITY work.Execution
GENERIC MAP(n => 16)
PORT MAP(

        IR1_IN              => IR1_DE_out,
        IR2_IN              => IR2_DE_out,
        SP                  => SP_Register_OUT,
        IR1_IN_NXT          => IR1_FD_out,                       -- IR1 of the next packet
        INPUT_PORT          => pport,
---------------------------------------------------------------
        Flag_Reg            => Flag_Register_OUT,
        dummy_CLK	    => CLK,
        ALU_As_Address1     => ALU_As_Address1_DE_out,
        SP_As_Address1      => SP_As_Address1_DE_out,
        SET_Carry1          => SET_Carry1_DE_out,
        CLR_Carry1          => CLR_Carry1_DE_out,

        ALU1_Operation_Code => ALU1_OP_Code_DE_out,

        Operand1_ALU1       => ALU1_Operand1_E_in,
        Operand2_ALU1       => ALU1_Operand2_E_in,

        Two_Operand_Flag1   => Two_Operand_Instr1_Flag_DE_out,
        One_Or_Two_Flag1    => One_or_Two1_DE_out,

        ALU1_JMP_DST        => ALU1_Jump_DST,
        Taken1_OUT          => Taken1_Execute_out,
        ALU1_OUT            => ALU1_Execute_out,
----------------------------------------------------------------
        ALU_As_Address2     => ALU_As_Address2_DE_out,
        SP_As_Address2      => SP_As_Address2_DE_out,
        SET_Carry2          => SET_Carry2_DE_out,
        CLR_Carry2          => CLR_Carry2_DE_out,

        ALU2_Operation_Code => ALU2_OP_Code_DE_out,

        Operand1_ALU2       => ALU2_Operand1_E_in,
        Operand2_ALU2       => ALU2_Operand2_E_in,

        Two_Operand_Flag2   => Two_Operand_Instr2_Flag_DE_out,
        One_Or_Two_Flag2    => One_or_Two2_DE_out,

        ALU2_JMP_DST        => ALU2_Jump_DST,
        Taken2_OUT          => Taken2_Execute_out,
        ALU2_OUT            => ALU2_Execute_out,

        OUT_PORT            => pport,
        Flags_OUT           => Flags_Execute_out
);

--=================================================================
--============================  EM Buffer =========================
--=================================================================

Exe_Mem_Buffer:
ENTITY work.BUF
PORT MAP(
        EXT_CLK   => CLK,
        EXT_RST1  => RST_EM_Buffer1,
	EXT_RST2  => RST_EM_Buffer2,

	Stall     => '0',
        Flush     => '0',
---------------------------------------------------------
        IR1_IN             => IR1_DE_out,           -- OLD Registers ***********
        IR2_IN             => IR2_DE_out,
        PC_IN              => PC_DE_out,
        SP_IN              => SP_Register_OUT,
        Flags_IN           => Flag_Register_OUT,
---------------------------------------------------------        
        NOP1_IN            => NOP1_DE_out,
        Taken1_IN          => Taken1_DE_out,
        SET_Carry1_IN      => SET_Carry1_DE_out,
        CLR_Carry1_IN      => CLR_Carry1_DE_out,
        ALU1_OP_Code_IN    => ALU1_OP_Code_DE_out,
        ALU1_Operand1_IN   => ALU1_Operand1_E_in,
        ALU1_Operand2_IN   => ALU1_Operand2_E_in,
        Two_Operand_Instr1_Flag_IN => Two_Operand_Instr1_Flag_DE_out,
        One_or_Two1_IN     => One_or_Two1_DE_out,
        
        ALU1_Result_IN     => ALU1_Execute_out,

        NOP2_IN            => NOP2_DE_out,
        Taken2_IN          => Taken2_DE_out,
        SET_Carry2_IN      => SET_Carry2_DE_out,
        CLR_Carry2_IN      => CLR_Carry2_DE_out,
        ALU2_OP_Code_IN    => ALU2_OP_Code_DE_out,
        ALU2_Operand1_IN   => ALU2_Operand1_E_in,
        ALU2_Operand2_IN   => ALU2_Operand2_E_in,
        Two_Operand_Instr2_Flag_IN => Two_Operand_Instr2_Flag_DE_out,
        One_or_Two2_IN     => One_or_Two2_DE_out,
        
        ALU2_Result_IN     => ALU2_Execute_out,

--------------------------------------------------------
        Memory_Read1_IN    => Memory_Read1_DE_out,
        Memory_Write1_IN   => Memory_Write1_DE_out,
        ALU_As_Address1_IN => ALU_As_Address1_DE_out,
        SP_As_Address1_IN  => SP_As_Address1_DE_out,
        PC_As_Data1_IN     => PC_As_Data1_DE_out,

        Memory_Read2_IN    => Memory_Read2_DE_out,
        Memory_Write2_IN   => Memory_Write2_DE_out,
        ALU_As_Address2_IN => ALU_As_Address2_DE_out,
        SP_As_Address2_IN  => SP_As_Address2_DE_out,
        PC_As_Data2_IN     => PC_As_Data2_DE_out,

        Memory_Result_IN   => Memory_Result_DE_out,
-----------------------------------------------------------
        Rsrc_Idx1_IN       => Rsrc_Idx1_DE_out,
        Rdst_Idx1_IN       => Rdst_Idx1_DE_out,
        Enable_SP1_IN      => Enable_SP1_DE_out,
        Enable_Reg1_IN     => Enable_Reg1_DE_out,
        Mem_or_ALU1_IN     => Mem_or_ALU1_DE_out,

        Rsrc_Idx2_IN       => Rsrc_Idx2_DE_out,
        Rdst_Idx2_IN       => Rdst_Idx2_DE_out,
        Enable_SP2_IN      => Enable_SP2_DE_out,
        Enable_Reg2_IN     => Enable_Reg2_DE_out,
        Mem_or_ALU2_IN     => Mem_or_ALU2_DE_out,

--==========================================================
--==========================================================
        IR1_OUT            => IR1_EM_out,
        IR2_OUT            => IR2_EM_out,
        PC_OUT             => PC_EM_out,
        SP_OUT             => SP_EM_out,
        Flags_OUT          => Flags_EM_out,
------------------------------------------------------------
        NOP1_OUT           => NOP1_EM_out,
        Taken1_OUT         => Taken1_EM_out,
        SET_Carry1_OUT     => SET_Carry1_EM_out,
        CLR_Carry1_OUT     => CLR_Carry1_EM_out,
        ALU1_OP_Code_OUT   => ALU1_OP_Code_EM_out,
        ALU1_Operand1_OUT  => ALU1_Operand1_EM_out,
        ALU1_Operand2_OUT  => ALU1_Operand2_EM_out,
        Two_Operand_Instr1_Flag_OUT => Two_Operand_Instr1_Flag_EM_out,
        One_or_Two1_OUT    => One_or_Two1_EM_out,
        ALU1_Result_OUT    => ALU1_Result_EM_out,

        NOP2_OUT           => NOP2_EM_out,
        Taken2_OUT         => Taken2_EM_out,
        SET_Carry2_OUT     => SET_Carry2_EM_out,
        CLR_Carry2_OUT     => CLR_Carry2_EM_out,
        ALU2_OP_Code_OUT   => ALU2_OP_Code_EM_out,
        ALU2_Operand1_OUT  => ALU2_Operand1_EM_out,
        ALU2_Operand2_OUT  => ALU2_Operand2_EM_out,
        Two_Operand_Instr2_Flag_OUT => Two_Operand_Instr2_Flag_EM_out,
        One_or_Two2_OUT    => One_or_Two2_EM_out,
        ALU2_Result_OUT    => ALU2_Result_EM_out,
-----------------------------------------------------------------
        Memory_Read1_OUT   => Memory_Read1_EM_out,
        Memory_Write1_OUT  => Memory_Write1_EM_out,
        ALU_As_Address1_OUT => ALU_As_Address1_EM_out,
        SP_As_Address1_OUT => SP_As_Address1_EM_out,
        PC_As_Data1_OUT    => PC_As_Data1_EM_out,

        Memory_Read2_OUT   => Memory_Read2_EM_out,
        Memory_Write2_OUT  => Memory_Write2_EM_out,
        ALU_As_Address2_OUT => ALU_As_Address2_EM_out,
        SP_As_Address2_OUT => SP_As_Address2_EM_out,
        PC_As_Data2_OUT    => PC_As_Data2_EM_out,
        
        Memory_Result_OUT  => Memory_Result_EM_out,
-----------------------------------------------------------
        Rsrc_Idx1_OUT      => Rsrc_Idx1_EM_out,
        Rdst_Idx1_OUT      => Rdst_Idx1_EM_out,
        Enable_SP1_OUT     => Enable_SP1_EM_out,
        Enable_Reg1_OUT    => Enable_Reg1_EM_out,
        Mem_or_ALU1_OUT    => Mem_or_ALU1_EM_out,

        Rsrc_Idx2_OUT      => Rsrc_Idx2_EM_out,
        Rdst_Idx2_OUT      => Rdst_Idx2_EM_out,
        Enable_SP2_OUT     => Enable_SP2_EM_out,
        Enable_Reg2_OUT    => Enable_Reg2_EM_out,
        Mem_or_ALU2_OUT    => Mem_or_ALU2_EM_out
);

--=============================================================
--===================== Memory Stage ==========================
--=============================================================

Memory_Stage:
ENTITY work.Memory
GENERIC MAP(n => 16, m => 20)
PORT MAP(
        EXT_CLK           => CLK,
        EXT_INTR          => Interrupt,

        IR1_IN             => IR1_EM_out,           -- OLD Registers ***********
        IR2_IN             => IR2_EM_out,

        PC                => PC_EM_out,
        SP                => SP_EM_out,

        Rsrc1             => ALU1_Operand1_EM_out(15 DOWNTO 0),
        Rdst1             => ALU1_Operand2_EM_out(15 DOWNTO 0),

        Read_Enable1      => Memory_Read1_EM_out,
        Write_Enable1     => Memory_Write1_EM_out,
        ALU_As_Address1   => ALU_As_Address1_EM_out,
        SP_As_Address1    => SP_As_Address1_EM_out,
        PC_As_Data1       => PC_As_Data1_EM_out,

        ALU1_OUT          => ALU1_Result_EM_out,
---------------------------------------------------------------
        Rsrc2             => ALU2_Operand1_EM_out(15 DOWNTO 0),
        Rdst2             => ALU2_Operand2_EM_out(15 DOWNTO 0),

        Read_Enable2      => Memory_Read2_EM_out,
        Write_Enable2     => Memory_Write2_EM_out,
        ALU_As_Address2   => ALU_As_Address2_EM_out,
        SP_As_Address2    => SP_As_Address2_EM_out,
        PC_As_Data2       => PC_As_Data2_EM_out,

        ALU2_OUT          => ALU2_Result_EM_out,
        
        RET1_OUT           => RET1_memory_out,
        RET2_OUT           => RET2_memory_out,
        Memory_OUT        => Memory_Memory_out
);

--=================================================================
--============================  MW Buffer =========================
--=================================================================

Mem_WB_Buffer:
ENTITY work.BUF
PORT MAP(
        EXT_CLK   => CLK,
        EXT_RST1  => RST_MW_Buffer1,
	EXT_RST2  => RST_MW_Buffer2,

	Stall     => '0',
        Flush     => '0',
-------------------------------------------------------------
        IR1_IN             => IR1_EM_out,           -- OLD Registers ***********
        IR2_IN             => IR2_EM_out,
        PC_IN              => PC_EM_out,
        SP_IN              => SP_EM_out,
        Flags_IN           => Flag_Register_OUT,
-------------------------------------------------------------
        NOP1_IN            => NOP1_EM_out,
        Taken1_IN          => Taken1_EM_out,
        SET_Carry1_IN      => SET_Carry1_EM_out,
        CLR_Carry1_IN      => CLR_Carry1_EM_out,
        ALU1_OP_Code_IN    => ALU1_OP_Code_EM_out,
        ALU1_Operand1_IN   => ALU1_Operand1_EM_out,
        ALU1_Operand2_IN   => ALU1_Operand2_EM_out,
        Two_Operand_Instr1_Flag_IN => Two_Operand_Instr1_Flag_EM_out,
        One_or_Two1_IN     => One_or_Two1_EM_out,
        
        ALU1_Result_IN     => ALU1_Result_EM_out,

        NOP2_IN            => NOP2_EM_out,
        Taken2_IN          => Taken2_EM_out,
        SET_Carry2_IN      => SET_Carry2_EM_out,
        CLR_Carry2_IN      => CLR_Carry2_EM_out,
        ALU2_OP_Code_IN    => ALU2_OP_Code_EM_out,
        ALU2_Operand1_IN   => ALU2_Operand1_EM_out,
        ALU2_Operand2_IN   => ALU2_Operand2_EM_out,
        Two_Operand_Instr2_Flag_IN => Two_Operand_Instr2_Flag_EM_out,
        One_or_Two2_IN     => One_or_Two2_EM_out,
        
        ALU2_Result_IN     => ALU2_Result_EM_out,
-------------------------------------------------------------
        Memory_Read1_IN    => Memory_Read1_EM_out,
        Memory_Write1_IN   => Memory_Write1_EM_out,
        ALU_As_Address1_IN => ALU_As_Address1_EM_out,
        SP_As_Address1_IN  => SP_As_Address1_EM_out,
        PC_As_Data1_IN     => PC_As_Data1_EM_out,

        Memory_Read2_IN    => Memory_Read2_EM_out,
        Memory_Write2_IN   => Memory_Write2_EM_out,
        ALU_As_Address2_IN => ALU_As_Address2_EM_out,
        SP_As_Address2_IN  => SP_As_Address2_EM_out,
        PC_As_Data2_IN     => PC_As_Data2_EM_out,

        Memory_Result_IN   => Memory_Memory_out,
-------------------------------------------------------------
        Rsrc_Idx1_IN       => Rsrc_Idx1_EM_out,
        Rdst_Idx1_IN       => Rdst_Idx1_EM_out,
        Enable_SP1_IN      => Enable_SP1_EM_out,
        Enable_Reg1_IN     => Enable_Reg1_EM_out,
        Mem_or_ALU1_IN     => Mem_or_ALU1_EM_out,

        Rsrc_Idx2_IN       => Rsrc_Idx2_EM_out,
        Rdst_Idx2_IN       => Rdst_Idx2_EM_out,
        Enable_SP2_IN      => Enable_SP2_EM_out,
        Enable_Reg2_IN     => Enable_Reg2_EM_out,
        Mem_or_ALU2_IN     => Mem_or_ALU2_EM_out,

--==========================================================
--==========================================================
        IR1_OUT            => IR1_MW_out,
        IR2_OUT            => IR2_MW_out,
        PC_OUT             => PC_MW_out,
        SP_OUT             => SP_MW_out,
        Flags_OUT          => Flags_MW_out,
------------------------------------------------------------
        NOP1_OUT           => NOP1_MW_out,
        Taken1_OUT         => Taken1_MW_out,
        SET_Carry1_OUT     => SET_Carry1_MW_out,
        CLR_Carry1_OUT     => CLR_Carry1_MW_out,
        ALU1_OP_Code_OUT   => ALU1_OP_Code_MW_out,
        ALU1_Operand1_OUT  => ALU1_Operand1_MW_out,
        ALU1_Operand2_OUT  => ALU1_Operand2_MW_out,
        Two_Operand_Instr1_Flag_OUT => Two_Operand_Instr1_Flag_MW_out,
        One_or_Two1_OUT    => One_or_Two1_MW_out,
        ALU1_Result_OUT    => ALU1_Result_MW_out,

        NOP2_OUT           => NOP2_MW_out,
        Taken2_OUT         => Taken2_MW_out,
        SET_Carry2_OUT     => SET_Carry2_MW_out,
        CLR_Carry2_OUT     => CLR_Carry2_MW_out,
        ALU2_OP_Code_OUT   => ALU2_OP_Code_MW_out,
        ALU2_Operand1_OUT  => ALU2_Operand1_MW_out,
        ALU2_Operand2_OUT  => ALU2_Operand2_MW_out,
        Two_Operand_Instr2_Flag_OUT => Two_Operand_Instr2_Flag_MW_out,
        One_or_Two2_OUT    => One_or_Two2_MW_out,
        ALU2_Result_OUT    => ALU2_Result_MW_out,
----------------------------------------------------------------

        Memory_Read1_OUT   => Memory_Read1_MW_out,
        Memory_Write1_OUT  => Memory_Write1_MW_out,
        ALU_As_Address1_OUT => ALU_As_Address1_MW_out,
        SP_As_Address1_OUT => SP_As_Address1_MW_out,
        PC_As_Data1_OUT    => PC_As_Data1_MW_out,

        Memory_Read2_OUT   => Memory_Read2_MW_out,
        Memory_Write2_OUT  => Memory_Write2_MW_out,
        ALU_As_Address2_OUT => ALU_As_Address2_MW_out,
        SP_As_Address2_OUT => SP_As_Address2_MW_out,
        PC_As_Data2_OUT    => PC_As_Data2_MW_out,
        
        Memory_Result_OUT  => Memory_Result_MW_out,
-----------------------------------------------------------------
        Rsrc_Idx1_OUT      => Rsrc_Idx1_MW_out,
        Rdst_Idx1_OUT      => Rdst_Idx1_MW_out,
        Enable_SP1_OUT     => Enable_SP1_MW_out,
        Enable_Reg1_OUT    => Enable_Reg1_MW_out,
        Mem_or_ALU1_OUT    => Mem_or_ALU1_MW_out,

        Rsrc_Idx2_OUT      => Rsrc_Idx2_MW_out,
        Rdst_Idx2_OUT      => Rdst_Idx2_MW_out,
        Enable_SP2_OUT     => Enable_SP2_MW_out,
        Enable_Reg2_OUT    => Enable_Reg2_MW_out,
        Mem_or_ALU2_OUT    => Mem_or_ALU2_MW_out
);

--=============================================================
--===================== WriteBack Stage ==========================
--=============================================================

WriteBack_Stage:
ENTITY work.WB
PORT MAP(
        IR1_IN    =>  IR1_MW_out,
        IR2_IN    =>  IR2_MW_out,

        ALU1      =>  ALU1_Result_MW_out,
        ALU2      =>  ALU2_Result_MW_out,
        SP        =>  SP_MW_out,
        MEM       =>  Memory_Result_MW_out,
        
        InPort    =>  pport,

        S1        =>  Mem_or_ALU1_MW_out,
        S2        =>  Mem_or_ALU2_MW_out,
        en1SP     =>  Enable_SP1_MW_out,
        en2SP     =>  Enable_SP2_MW_out,
        enWrite1  =>  Enable_Reg1_MW_out,
        enWrite2  =>  Enable_Reg2_MW_out,
        reg1Index =>  Rdst_Idx1_MW_out,
        reg2Index =>  Rdst_Idx2_MW_out,

        SPout     =>  SP_WB_out,
        index1    =>  index1_WB_out,
        index2    =>  index2_WB_out,
        Data1     =>  Data1_WB_out,
        Data2     =>  Data2_WB_out,
        Write1out =>  Write1_WB_out,
        Write2out =>  Write2_WB_out
);

--=============================================================
--===================== Register File ==========================
--=============================================================

RegisterFile:
ENTITY work.Register_File
GENERIC MAP(n => 16)
PORT MAP(
	Reg_CLK         => CLK,
	Reg_RST         => '0',
        
        EnableWrite1    => Write1_WB_out,
        EnableWrite2    => Write2_WB_out,
        Rdst_Idx1       => index1_WB_out,
        Rdst_Idx2       => index2_WB_out,
        Data1           => Data1_WB_out,
        Data2           => Data2_WB_out,

        Reg0_OUT        => Register0_OUTPUT,
        Reg1_OUT        => Register1_OUTPUT,
        Reg2_OUT        => Register2_OUTPUT,
        Reg3_OUT        => Register3_OUTPUT,
        Reg4_OUT        => Register4_OUTPUT,
        Reg5_OUT        => Register5_OUTPUT,
        Reg6_OUT        => Register6_OUTPUT,
        Reg7_OUT        => Register7_OUTPUT
);

END ARCHITECTURE;
