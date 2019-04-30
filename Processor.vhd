LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;

Entity Processor is
    port( CLK,RST,Interrupt: IN  STD_LOGIC;
          pport : INOUT STD_LOGIC_Vector(15 Downto 0)
    );
end entity Processor;


architecture flow of Processor is

--------------------------------------------      SIGNALS      ----------------------------------------------

--------------------------------------------  FETCH TO BUFFER  ----------------------------------------------

signal IR1_Fetch_out, IR2_Fetch_out : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);


--------------------------------------------------------------------------------------------------------------
--------------------------------------------    IF\ID Buffer    ----------------------------------------------

signal	IR1_FD_out, IR2_FD_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_FD_out, SP_FD_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_FD_out          		                                	    :  STD_LOGIC_VECTOR (3 DOWNTO 0);

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
        			
signal	Memory_Result_FD_out	        	                                : STD_LOGIC_VECTOR (15 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_FD_out, Rdst_Idx1_FD_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_FD_out, Enable_Reg1_FD_out, Mem_or_ALU1_FD_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_FD_out, Rdst_Idx2_FD_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_FD_out, Enable_Reg2_FD_out, Mem_or_ALU2_FD_out			: STD_LOGIC;             


--------------------------------------------------------------------------------------------------------------     
--------------------------------------------   Decode TO Buffer  ----------------------------------------------

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
        			
signal	Memory_Result_Decode_out	        	                            : STD_LOGIC_VECTOR (15 DOWNTO 0);

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

signal	IR1_DE_out, IR2_DE_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_DE_out, SP_DE_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_DE_out          		                                	    :  STD_LOGIC_VECTOR (3 DOWNTO 0);

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
        			
signal	Memory_Result_DE_out	        	                                : STD_LOGIC_VECTOR (15 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_DE_out, Rdst_Idx1_DE_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_DE_out, Enable_Reg1_DE_out, Mem_or_ALU1_DE_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_DE_out, Rdst_Idx2_DE_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_DE_out, Enable_Reg2_DE_out, Mem_or_ALU2_DE_out			: STD_LOGIC;             


---------------------------------------------------------------------------------------------------------------     
--------------------------------------------  Execute to Buffer  ----------------------------------------------

signal ALU1_Execute_out, ALU2_Execute_out                                   : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal Flags_Execute_out		                                            : STD_LOGIC_VECTOR( 2 DOWNTO 0);

--------------------------------------------------------------------------------------------------------------     
--------------------------------------------  Ex\Mem Buffer  ----------------------------------------------

signal	IR1_EM_out, IR2_EM_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_EM_out, SP_EM_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_EM_out          		                                	    :  STD_LOGIC_VECTOR (3 DOWNTO 0);

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
        			
signal	Memory_Result_EM_out	        	                                : STD_LOGIC_VECTOR (15 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_EM_out, Rdst_Idx1_EM_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_EM_out, Enable_Reg1_EM_out, Mem_or_ALU1_EM_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_EM_out, Rdst_Idx2_EM_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_EM_out, Enable_Reg2_EM_out, Mem_or_ALU2_EM_out			: STD_LOGIC;             


---------------------------------------------------------------------------------------------------------------     
--------------------------------------------  Memory to Buffer  ----------------------------------------------

signal Memory_Memory_out                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);


--------------------------------------------------------------------------------------------------------------     
--------------------------------------------    Mem\WB Buffer    ----------------------------------------------

signal	IR1_MW_out, IR2_MW_out       		                                :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	    
signal	PC_MW_out, SP_MW_out            		                        	:  STD_LOGIC_VECTOR(31 DOWNTO 0);
                    			
signal	Flags_MW_out          		                                	    :  STD_LOGIC_VECTOR (3 DOWNTO 0);

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
        			
signal	Memory_Result_MW_out	        	                                : STD_LOGIC_VECTOR (15 DOWNTO 0);

---- For Channel 1
	
signal	Rsrc_Idx1_MW_out, Rdst_Idx1_MW_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);

signal	Enable_SP1_MW_out, Enable_Reg1_MW_out, Mem_or_ALU1_MW_out		    : STD_LOGIC;      

---- For Channel 2
signal	Rsrc_Idx2_MW_out, Rdst_Idx2_MW_out                				    : STD_LOGIC_VECTOR (2 DOWNTO 0);
				
signal	Enable_SP2_MW_out, Enable_Reg2_MW_out, Mem_or_ALU2_MW_out			: STD_LOGIC;             


---------------------------------------------------------------------------------------------------------------     
----------------------------------------  WriteBack to Register File  -------------------------------------------

signal SP_Execute_out                                                       : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal Data1_Execute_out, Data2_Execute_out                                 : std_logic_vector(15 downto 0);

signal index1_Execute_out, index2_Execute_out                               : std_logic_vector(2 downto 0)

signal Write1_Execute_out, Write2_Execute_out                               : std_logic;

--------------------------------------------------------------------------------------------------------------
------------------------------------    E N D    O F    S I G N A L S   --------------------------------------
--------------------------------------------------------------------------------------------------------------


begin
        



end flow;