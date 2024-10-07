import numpy as np
from scipy import linalg

C1=A+B
C2=np.matmul(A,B)
C3=np.eye(param1, param1)
C4=linalg.inv(A)

ReturnList = [C1, C2, C3, C4]