romagurung@romagurung-AOD271:~/OpenCalphad_Projects/OC_V3_2015_12_29_30/opencalphad-version3$ ./oc3B 

Open Calphad (OC) software version  3.0 linked 2015-12-30
with command line monitor version 21

This program is available with a GNU General Public License.
It includes the General Thermodynamic Package, version GTP-3.00
and Hillert's equilibrium calculation algorithm version HMS-2.00
and step/map/plot software version SMP-1.10
and LMDIF (1980) from Argonne is used by the assessment procedure

OC3:mac map_sac1
OC3:OC3: Hit RETURN to continue

OC3:OC3:On? /Y/: OC3:... echo: r t agbicupbsbsn
Database has  6 elements: AG BI CU PB SB SN
Give the elements to select, finish with empty line
Select elements /all/:... echo: sn ag cu
Select elements /no more/:Selected  3 elements: SN AG CU
There are     8 bibliographic references
REF: 91DIN      '*** Not set by database or user'
REF: 86HAY      '*** Not set by database or user'
REF: 96OH       '*** Not set by database or user'
REF: 96SHI      '*** Not set by database or user'
REF: 0          '*** Not set by database or user'
REF283          'Alan Dinsdale, SGTE Data for Pure Elements, Calphad Vol 
                 15(1991) p 317-425, also in NPL Report DMA(A)195 Rev. August 
                 1990'
REF135          '*** Not set by database or user'
REF: 86JON      '*** Not set by database or user'

OC3:... echo: @$-------------------------------------------------------------------
OC3:... echo: @&
 Hit RETURN to continue

OC3:... echo: @$ Calculate an equilibrium in the miscibility gap
OC3:... echo: @$ A second composition set is created by the grid minimizer
OC3:OC3:... echo: set cond t=523.15 p=1e5 n=1 x(cu)=0.0130 x(ag)=0.0382
OC3:OC3:... echo: c e
 Composition set(s) created:            1
Gridmin:     114 points   1.21E-02 s and      10 clockcycles, T=  523.15
Phase change: its/add/remove:     5    0    1
Phase change: its/add/remove:    15    0    7
Equilibrium calculation   19 its,   5.0002E-02 s and      50 clockcycles
OC3:OC3:... echo: l r 1
Output for equilibrium:   1, DEFAULT_EQUILIBRIUM          2016.03.15
Conditions .................................................:
  1:T=523.15, 2:P=100000, 3:N=1, 4:X(CU)=.013, 5:X(AG)=.0382
 Degrees of freedom are   0

Some global data, reference state SER ......................:
T=    523.15 K (   250.00 C), P=  1.0000E+05 Pa, V=  0.0000E+00 m3
N=   1.0000E+00 moles, B=   1.1756E+02 g, RT=   4.3497E+03 J/mol
G= -2.9393E+04 J, G/N= -2.9393E+04 J/mol, H=  1.3864E+04 J, S=  8.2686E+01 J/K

Some data for components ...................................:
Component name    Moles      Mole-fr  Chem.pot/RT  Activities  Ref.state
AG                3.8200E-02  0.03820 -7.4815E+00  5.6344E-04  SER (default)   
CU                1.3000E-02  0.01300 -7.9224E+00  3.6252E-04  SER (default)   
SN                9.4880E-01  0.94880 -6.7124E+00  1.2157E-03  SER (default)   

Some data for phases .......................................:
Name                Status Moles      Volume    Form.Units  At/FU dGm/RT  Comp:
LIQUID.................. E  1.000E+00  0.00E+00  1.00E+00    1.00  0.00E+00  X:
 SN     9.48800E-01  AG     3.82000E-02  CU     1.30000E-02

OC3:OC3:... echo: @$-------------------------------------------------------------------
OC3:... echo: @&
 Hit RETURN to continue

OC3:... echo: @$ Set two axis for a phase diagram calculation
OC3:OC3:... echo: set ax 1 x(sn) 0 1 ,,,
 You must set the variable as a condition before setting it as axis

 Error codes:         4131           0
 No such condition                                               
OC3:... echo: set ax 2 t 400 640 10
 Axis must be set in sequential order, axis number set to            1
OC3:OC3:... echo: l ax
    Axis variable            Min         Max         Max increment
 1  T                         4.0000E+02  6.4000E+02  1.0000E+01
OC3:OC3:... echo: l sh
Option /A/: Equilibrium name         Gas constant Pressure norm                      Status
 DEFAULT_EQUILIBRIUM       8.3145E+00    1.0000E+00                           1

List of elements
 No Sym Name          Reference state            Mass  H298-H0   S298    Status
 -1  /- Electron      Electron_gas               0.000    0.00   0.000        0
  0  VA Vacancy       Vaccum                     0.000    0.00   0.000        0
  1  AG AG            FCC_A1                   107.870 5744.60  42.551        0
  2  CU CU            FCC_A1                    63.546 5004.10  33.150        0
  3  SN SN            BCT_A5                   118.690 6322.00  51.195        0

List of species
  No Symbol                    Stoichiometry            Mass      Charge Status
   1 AG                        AG                         107.870   0.0       4
   2 CU                        CU                          63.546   0.0       4
   3 SN                        SN                         118.690   0.0       4
   4 VA                        VA                           0.000   0.0       C

List of  14 phases
  No tup Name                      Mol.comp. At/F.U.   dGm/RT  Status1  Status2
   1   1 LIQUID                    1.00E+00     1.00       0.0     410       0S
   2   2 BCC_A2                         0.0     1.00 -2.61E+00      10       0U
   3   3 BCT_A5                         0.0     1.00 -1.08E-01      10       0U
   4   4 CU10SN3                        0.0     1.00 -1.04E+00      18       0U
   5   5 CU3SN                          0.0     1.00 -7.71E-01      18       0U
   6   6 CU41SN11                       0.0     1.00 -1.20E+00      18       0U
   7   7 CU6SN5                         0.0     1.00 -3.78E-01      18       0U
   8   8 CU6SN5_L                       0.0     1.00 -3.86E-01      18       0U
   9   9 DO3                            0.0     1.00 -3.98E-01      10       0U
  10  10 EPSILON                        0.0     1.00 -2.97E-01      18       0U
  11  11 FCC_A1                         0.0     1.00 -1.96E+00      10       0U
  12  12 HCP_A3                         0.0     1.00 -2.06E+00      10       0U
  13  13 RHOMBO_A7                      0.0     1.00 -5.77E-01      1C       0U
  14  14 SBSN                           0.0     2.00 -4.27E+00      18       0U
OC3:... echo: @$-------------------------------------------------------------------
OC3:... echo: @&
 Hit RETURN to continue

OC3:... echo: @$ Set reference state for the elements
OC3:... echo: set ref ag fcc,,,,,
OC3:... echo: set ref cu fcc,,,,,
OC3:... echo: set ref sn bct,,,,,
OC3:OC3:... echo: @$-------------------------------------------------------------------
OC3:... echo: @&
 Hit RETURN to continue

OC3:OC3:... echo: map
 You must set two axis with independent variables
OC3:OC3:OC3:... echo: @$-------------------------------------------------------------------
OC3:... echo: @&
 Hit RETURN to continue

OC3:... echo: @$ Plot with X-T axis
OC3:... echo: plot
 You must give a STEP or MAP command before PLOT
OC3:... echo: x(*,sn)
