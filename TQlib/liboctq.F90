!
! Minimal TQ interface.
!
! To compile and link this with an application one must first compile
! and form a library with of the most OC subroutines (oclib.a)
!  and to copy this and the corresponding "mov" files from this compilation 
! to the folder with this library
!
! NOTE that for the identification of phase and composition sets this
! TQ interface use a Fortran TYPE called gtp_phasetuple containing two
! integers, "phase" with the phase number and "compset" with the
! comp.set The number of phase tuples is initially equal to the number
! of phases and have the same index.  This represent comp.set 1 of the
! phases.  A phase may have several comp.sets created by calculations
! or by commands and these will have phase tuple index higher than the
! number of phases and they are in the order they were created.  This
! may cause some problems as internally in OC all comp.sets are
! ordered sequantially for each phase.  If a comp.set is removed those
! with higher index will be moved down so there are no gaps.  So do
! not delete comp.sets or at least be very careful when deleting
! comp.sets.
!
! When not using Fortran 95 (or later) one can probably replace this
! with a 2-dimensional array with first index phase number and second
! the comp.set number.
!
! For constituents an EXTENDED CONSTITUENT INDEX is sometimes used 
! and equal to 10*species_number + sublattice
!
! 141210 BOS changed to use phase tuples
! 140128 BOS added D2G and phase specific V and G
! 140128 BOS added possibility to calculate without invoking grid minimizer
! 140125 BOS Changed name to liboctq
! 140123 BOS Added ouput of MQ G, V and normalized
!
! The name of this librqry
module liboctq
!
! access to main OC library for equilibrium calculations and models
  use liboceq
!
  implicit none
!
  integer, parameter :: maxc=20,maxp=100
!
! This is for storage and use of components
  integer nel
  character, dimension(maxc) :: cnam*24
! This is for storage and use of phase+composition tuples
  integer ntup
  type(gtp_phasetuple), dimension(maxp) :: phcs
!
contains
!
!\begin{verbatim}
  subroutine tqini(n,ceq)
! initiate workspace
    implicit none
    integer n ! Not nused, could be used for some initial allocation
    type(gtp_equilibrium_data), pointer :: ceq ! EXIT: current equilibrium
!\end{verbatim}
! these should be provide linits and defaults
    integer intv(10)
    double precision dblv(10)
    intv(1)=-1
! This call initiates the OC package
    call init_gtp(intv,dblv)
1000 continue
    return
  end subroutine tqini

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqrfil(filename,ceq)
! read all elements from a TDB file
    implicit none
    character*(*) filename  ! IN: database filename
    character ellista(10)*2  ! dummy
    type(gtp_equilibrium_data), pointer :: ceq !IN: current equilibrium
!\end{verbatim}
    integer iz
    character elname*2,name*24,refs*24
    double precision a1,a2,a3
! second argument 0 means ellista is ignored, all element read
    call readtdb(filename,0,ellista)
    ceq=>firsteq
    nel=noel()
    do iz=1,nel
! store element name in module array components
       call get_element_data(iz,elname,name,refs,a1,a2,a3)
       cnam(iz)=elname
    enddo
! store phase tuples and indices
    ntup=get_phtuplearray(phcs)
1000 continue
    return
  end subroutine tqrfil

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqrpfil(filename,nsel,selel,ceq)
! read TDB file with selection of elements
    implicit none
    character*(*) filename  ! IN: database filename
    integer nsel,i
    character selel(*)*2  ! IN: elements to be read from the database
    type(gtp_equilibrium_data), pointer :: ceq !IN: current equilibrium
!\end{verbatim}
    integer iz
    character elname*2,name*24,refs*24
    double precision a1,a2,a3
!
    call readtdb(filename,nsel,selel)
    if(gx%bmperr.ne.0) goto 1000
    ceq=>firsteq
    nel=noel()
    do iz=1,nel
! store element name in module array components
       call get_element_data(iz,elname,name,refs,a1,a2,a3)
       cnam(iz)=elname
    enddo
! store phase tuples and indices
    ntup=get_phtuplearray(phcs)
1000 continue
    return
  end subroutine tqrpfil
 
!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgcom(n,compnames,ceq)
! get system component names. At present the elements
    implicit none
    integer n                               ! EXIT: number of components
    character*24, dimension(*) :: compnames ! EXIT: names of components
    type(gtp_equilibrium_data), pointer :: ceq  !IN: current equilibrium
!\end{verbatim}
    integer iz
    character elname*24,refs*24
    double precision a1,a2,a3
    do iz=1,nel
       compnames(iz)=' '
       call get_element_data(iz,compnames(iz),elname,refs,a1,a2,a3)
! store name in module array components also (already done when reading TDB)
       cnam(iz)=compnames(iz)
    enddo
1000 continue
    return
  end subroutine tqgcom

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgnp(n,ceq)
! get total number of phases and composition sets
! A second composition set of a phase is normally placed after all other
! phases with one composition set
    implicit none
    integer n    !EXIT: n is number of phases
    type(gtp_equilibrium_data), pointer :: ceq !IN: current equilibrium
!\end{verbatim}
! This call fills the module array phcs with phase and composition set indices
! NOTE the number composition sets may change at a calculation or if new
! composition sets are added or deleted explicitly
    ntup=get_phtuplearray(phcs)
    n=ntup
1000 continue
    return
  end subroutine tqgnp

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgpn(phcsx,phasename,ceq)
! get name of phase+compset tuple with index phcsx 
    implicit none
    integer phcsx                  ! IN: index in phase tuple array
!    TYPE(gtp_phasetuple), pointer :: phcs  !IN: phase number and comp.set
    character phasename*(*)      !EXIT: phase name, max 24+8 for pre/suffix
    type(gtp_equilibrium_data), pointer :: ceq !IN: current equilibrium
!\end{verbatim}
    call get_phase_name(phcs(phcsx)%phase,phcs(phcsx)%compset,phasename)
1000 continue
    return
  end subroutine tqgpn

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgpi(phcsx,phasename,ceq)
! get index of phase phasename (including comp.set, ceq not needed ...
    implicit none
    integer phcsx           !EXIT: phase tuple index
    character phasename*(*) !IN: phase name
    type(gtp_equilibrium_data), pointer :: ceq !IN: current equilibrium
!\end{verbatim}
    call find_phasetuple_by_name(phasename,phcsx)
1000 continue
    return
  end subroutine tqgpi

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgpcn(n,c,constituentname,ceq)
! get name of consitutent c in phase n
    implicit none
    integer n !IN: phase number
    integer c !IN: extended constituent index: 10*species_number+sublattice
    character constituentname*(24) !EXIT: costituent name
    type(gtp_equilibrium_data), pointer :: ceq !IN: current equilibrium
!\end{verbatim}
    write(*,*)'tqgpcn not implemented yet'
    gx%bmperr=8888
1000 continue
    return
  end subroutine tqgpcn

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgpci(n,c,constituentname,ceq)
! get index of constituent with name in phase n
    implicit none
    integer n !IN: phase index
    integer c !EXIT: extended constituent index: 10*species_number+sublattice
    character constituentname*(*)
    type(gtp_equilibrium_data), pointer :: ceq  !IN: current equilibrium
!\end{verbatim}
    write(*,*)'tqgpci not implemented yet'
    gx%bmperr=8888
1000 continue
    return
  end subroutine tqgpci

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgpcs(n,c,stoi,mass,ceq)
! get stoichiometry of constituent c in phase n 
!? missing argument number of elements????
    implicit none
    integer n !IN: phase number
    integer c !IN: extended constituent index: 10*species_number+sublattice
    double precision stoi(*) !EXIT: stoichiometry of elements 
    double precision mass    !EXIT: total mass
    type(gtp_equilibrium_data), pointer :: ceq  !IN: current equilibrium
!\end{verbatim}
    write(*,*)'tqgpcs not implemented yet'
    gx%bmperr=8888
1000 continue
    return
  end subroutine tqgpcs

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgccf(n1,n2,elnames,stoi,mass,ceq)
! get stoichiometry of component n1
! n2 is number of elements (dimension of elnames and stoi)
    implicit none
    integer n1 !IN: component number
    integer n2 !EXIT: number of elements in component
    character elnames(*)*(2) ! EXIT: element symbols
    double precision stoi(*) ! EXIT: element stoichiometry
    double precision mass    ! EXIT: component mass (sum of element mass)
    type(gtp_equilibrium_data), pointer :: ceq  !IN: current equilibrium
!\end{verbatim}
    write(*,*)'tqgccf not implemented yet'
    gx%bmperr=8888
1000 continue
    return
  end subroutine tqgccf

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgnpc(n,c,ceq)
! get number of constituents of phase n
    implicit none
    integer n !IN: Phase number
    integer c !EXIT: number of constituents
    type(gtp_equilibrium_data), pointer :: ceq  !IN: current equilibrium
!\end{verbatim}
    write(*,*)'tqgnpc not implemented yet'
    gx%bmperr=8888
1000 continue
    return
  end subroutine tqgnpc

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqphsts(tup,newstat,val,ceq)
! set status of phase tuple, 
    integer tup,newstat
    double precision val
    type(gtp_equilibrium_data), pointer :: ceq  ! IN: current equilibrium
!\end{verbatim}
    integer n
    if(tup.le.0) then
       do n=1,ntup
          call change_phase_status(phcs(n)%phase,phcs(n)%compset,&
               newstat,val,ceq)
          if(gx%bmperr.ne.0) goto 1000
       enddo
    elseif(tup.le.ntup) then
       call change_phase_status(phcs(tup)%phase,phcs(tup)%compset,&
            newstat,val,ceq)
    else
       write(*,*)'Illegal phase tuple index'
       gx%bmperr=5001
    endif
1000 continue
    return
  end subroutine tqphsts

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqsetc(stavar,n1,n2,value,cnum,ceq)
! set condition
! stavar is state variable as text
! n1 and n2 are auxilliary indices
! value is the value of the condition
! cnum is returned as an index of the condition.
! to remove a condition the value sould be equial to RNONE ????
! when a phase indesx is needed it should be 10*nph + ics
! SEE TQGETV for doucumentation of stavar etc.
    implicit none
    integer n1             ! IN: 0 or phase tuple index or component number
    integer n2             ! IN: 0 or component number
    integer cnum           ! EXIT: sequential number of this condition
    character stavar*(*)   ! IN: character with state variable symbol
    double precision value ! IN: value of condition
    type(gtp_equilibrium_data), pointer :: ceq  ! IN: current equilibrium
!\end{verbatim}
    integer ip
    character cline*60,selvar*4
!
!    write(*,11)'In tqsetc ',stavar(1:len_trim(stavar)),n1,n2,value
11  format(a,a,2i5,1pe14.6)
    cline=' '
    selvar=stavar
    call capson(selvar)
    select case(selvar)
    case default
       write(*,*)'Condition wrong, not implemented or illegal: ',stavar
       gx%bmperr=8888; goto 1000
! Potentials T and P
    case('T   ','P   ')
       write(cline,110)selvar(1:1),value
110    format(' ',a,'=',E15.8)
! Total amount or amount of a component in moles
    case('N   ')
       if(n1.gt.0) then
!          call get_component_name(n1,name,ceq)
!          if(gx%bmperr.ne.0) goto 1000
          write(cline,112)selvar(1:1),cnam(n1)(1:len_trim(cnam(n1))),value
112       format(' ',a,'(',a,')=',E15.8)
       else
          write(cline,110)selvar(1:1),value
       endif
! Overall fraction of a component 
    case('X   ','W   ')
! ?? fraction of phase component not implemented, n1 must be component number
!       call get_component_name(n1,cnam,ceq)
!       if(gx%bmperr.ne.0) goto 1000
       write(cline,120)selvar(1:1),cnam(n1)(1:len_trim(cnam(n1))),value
120    format(1x,a,'(',a,')=',1pE15.8)
! ?? MORE CONDITIONS WILL BE ADDED ...
    end select
!    write(*,*)'tqsetc: ',cline(1:len_trim(cline))
    ip=1
    call set_condition(cline,ip,ceq)
1000 continue
    return
  end subroutine tqsetc

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqce(target,n1,n2,value,ceq)
! calculate quilibrium with possible target
! Target can be empty or a state variable with indices n1 and n2
! value is the calculated value of target
    implicit none
    integer n1,n2,mode
    character target*(*)
    double precision value
    type(gtp_equilibrium_data), pointer :: ceq  !IN: current equilibrium
!\end{verbatim}
! mode=1 means start values using global gridminimization
    mode=1
    if(n1.lt.0) then
! this means calculate without grid minimuzer
       write(*,*)'No grid minimizer'
       mode=0
    endif
    call calceq2(mode,ceq)
    if(gx%bmperr.ne.0) goto 1000
! there may be new composition sets, update tup and phcs
! this call updates both the number of tuples and the phcs array
    ntup=get_phtuplearray(phcs)
1000 continue
    return
  end subroutine tqce

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

!\begin{verbatim}
  subroutine tqgetv(stavar,n1,n2,n3,values,ceq)
! get equilibrium results using state variables
! stavar is the state variable IN CAPITAL LETTERS with indices n1 and n2 
! n1 can be a phase tuple index, n2 a component index
! n3 at the call is the dimension of the array values, 
! changed to number of values on exit
! value is an array with the calculated value(s), n3 set to number of values.
    implicit none
    integer n1,n2,n3
    character stavar*(*)
    double precision values(*)
    type(gtp_equilibrium_data), pointer :: ceq  !IN: current equilibrium
!========================================================
! stavar must be a symbol listed below
! IMPORTANT: some terms explained after the table
! Symbol  index1,index2                     Meaning (unit)
!.... potentials
! T     0,0                                             Temperature (K)
! P     0,0                                             Pressure (Pa)
! MU    component,0 or ext.phase.index*1,constituent*2  Chemical potential (J)
! AC    component,0 or ext.phase.index,constituent      Activity = EXP(MU/RT)
! LNAC  component,0 or ext.phase.index,constituent      LN(activity) = MU/RT
!...... extensive variables
! U     0,0 or ext.phase.index,0   Internal energy (J) whole system or phase
! UM    0,0 or ext.phase.index,0       same per mole components
! UW    0,0 or ext.phase.index,0       same per kg
! UV    0,0 or ext.phase.index,0       same per m3
! UF    ext.phase.index,0              same per formula unit of phase
! S*3   0,0 or ext.phase.index,0   Entropy (J/K) 
! V     0,0 or ext.phase.index,0   Volume (m3)
! H     0,0 or ext.phase.index,0   Enthalpy (J)
! A     0,0 or ext.phase.index,0   Helmholtz energy (J)
! G     0,0 or ext.phase.index,0   Gibbs energy (J)
! ..... some extra state variables
! NP    ext.phase.index,0          Moles of phase
! BP    ext.phase.index,0          Mass of moles (kg)
! Q     ext.phase.index,0          Internal stability/RT (dimensionless)
! DG    ext.phase.index,0          Driving force/RT (dimensionless)
!....... amounts of components
! N     0,0 or component,0 or ext.phase.index,component    Moles of component
! X     component,0 or ext.phase.index,component   Mole fraction of component
! B     0,0 or component,0 or ext.phase.index,component     Mass of component
! W     component,0 or ext.phase.index,component   Mass fraction of component
! Y     ext.phase.index,constituent*1                    Constituent fraction
!........ some parameter identifiers
! TC    ext.phase.index,0                Magnetic ordering temperature
! BMAG  ext.phase.index,0                Aver. Bohr magneton number
! MQ&   ext.phase.index,constituent    Mobility
! THET  ext.phase.index,0                Debye temperature
! LNX   ext.phase.index,0                Lattice parameter
! EC11  ext.phase.index,0                Elastic constant C11
! EC12  ext.phase.index,0                Elastic constant C12
! EC44  ext.phase.index,0                Elastic constant C44
!........ NOTES:
! *1 The ext.phase.index is   10*phase_number+comp.set_number
! *2 The constituent index is 10*species_number + sublattice_number
! *3 S, V, H, A, G, NP, BP, N, B and DG can have suffixes M, W, V, F also
!--------------------------------------------------------------------
! special addition for TQ interface: d2G/dyidyj
! D2G + extended phase index
!--------------------------------------------------------------------
!\end{verbatim}
    integer ics,mjj,nph,ki,kj,lp,lokph,lokcs
    character statevar*60,encoded*60,name*24,selvar*4,norm*4
! mjj should be the dimension of the array values ...
    mjj=n3
    selvar=stavar
    call capson(selvar)
! for state variables like MQ&FE remove the part from & before the select
!    write(*,11)'In tqgetv: ',selvar,n1,n2,n3
11  format(a,a,3i5)
    norm=' '
    lp=index(selvar,'&')
    if(lp.gt.0) then
       selvar(lp:)=' '
    else
! check if variable is normallized
       ki=len_trim(selvar)
       if(ki.ge.2) then
          if(selvar(ki:ki).eq.'M') then
             norm='M'
             selvar(ki:)=' '
             ki=ki-1
          endif
       endif
    endif
!=======================================================================
    kj=index(selvar,'(')
    if(kj.gt.0) then
       selvar=selvar(1:kj-1)
    endif
!    write(*,*)'tqgetv 0: ',kj,selvar,'>',stavar,'<'
    select case(selvar)
    case default
       write(*,*)'Unknown state variable: ',stavar(1:20),'>:<',selvar
       gx%bmperr=8888; goto 1000
!--------------------------------------------------------------------
! chemical potential for a component
    case('MU  ')
       if(n1.le.0) then
          write(*,*)'tqgetv 17: component number must be positive'
          gx%bmperr=8888; goto 1000
       endif
!       call get_component_name(n1,name,ceq)
!       if(gx%bmperr.ne.0) goto 1000
       statevar=stavar(1:2)//'('//cnam(n1)(1:len_trim(cnam(n1)))//') '
!       write(*,*)'tqgetv 4: ',statevar(1:len_trim(statevar))
! we must use index value(1) as the subroutine expect a single variable
       call get_state_var_value(statevar,values(1),encoded,ceq)
!--------------------------------------------------------------------
! Amount of moles of components in a phaase
    case('NP  ')
       if(n1.lt.0) then
! all phases
          statevar='NP(*)'
!          write(*,*)'tqgetv 1: ',mjj,statevar(1:len_trim(statevar))
! hopefully this returns all composition sets for all phases ... YES!
          call get_many_svar(statevar,values,mjj,n3,encoded,ceq)
! this output gives the amounts for all compsets of a phase sequentially
! but here we want them in phase tuple order
! the second argument is the number of values for each phase, here is 1 but
! it can be for example compositions, then it should be number of components
          call sortinphtup(n3,1,values)
       else
! NOTE in this case n1 is a phase tuple index
!          ics=mod(n1,10)
!          nph=n1/10
!          if(nph.eq.0 .or. ics.eq.0) then
!             write(*,*)'You must use extended phase index'
!             gx%bmperr=8887; goto 1000
!          endif
!          call get_phase_name(nph,ics,name)
          call get_phase_name(phcs(n1)%phase,phcs(n1)%compset,name)
          if(gx%bmperr.ne.0) goto 1000
          statevar='NP('//name(1:len_trim(name))//') '
          call get_state_var_value(statevar,values(1),encoded,ceq)
          n3=1
       endif
!--------------------------------------------------------------------
! Mole or mass fractions
    case('X   ','W   ')
!       write(*,*)'tqgetv: ',n1,n2,n3
       if(n2.eq.0) then
          if(n1.lt.0) then
! mole �fraction of all components, no phase specification
             statevar=stavar(1:1)//'(*) '
!             write(*,*)'tqgetv 3: ',mjj,statevar(1:len_trim(statevar))
             call get_many_svar(statevar,values,mjj,n3,encoded,ceq)
          elseif(n1.eq.0) then
! mole fraction for the state variable written as X(FE)
! n1 and n2 not used, just check for wildcard
!             write(*,*)'tqgetv 20: ',stavar(1:len_trim(stavar))
             if(index(stavar,'*').gt.0) then
                call get_many_svar(stavar,values,mjj,n3,encoded,ceq)
             else
                call get_state_var_value(stavar,values(1),encoded,ceq)
             endif
          else
! mole fraction of a single component, no phase specification
             n3=1
             ics=1
!             call get_component_name(n1,name,ceq)
!             if(gx%bmperr.ne.0) goto 1000
             statevar=stavar(1:1)//'('//cnam(n1)(1:len_trim(cnam(n1)))//')'
!             write(*,*)'tqgetv 4: ',statevar(1:len_trim(statevar))
             call get_state_var_value(statevar,values(1),encoded,ceq)
          endif
       elseif(n1.lt.0) then
!........................................................
! for all phases one or several components
          if(n2.lt.0) then
! this means all components all phases
             statevar=stavar(1:1)//'(*,*) '
!             write(*,*)'tqgetv 5: ',mjj,statevar(1:len_trim(statevar))
             call get_many_svar(statevar,values,mjj,n3,encoded,ceq)
! this output gives the composition for all compsets of a phase sequentially
! but we want them in phase tuple order
! ??             call sortinphtup(n3,,values)
          else
! a single component in all phases. n2 must not be zero
!             call get_component_name(n2,name,ceq)
!             if(gx%bmperr.ne.0) goto 1000
             if(n2.le.0 .or. n2.ge.noel()) then
                write(*,*)'No such component'
                goto 1000
             endif
             statevar=stavar(1:1)//'(*,'//cnam(n2)(1:len_trim(cnam(n2)))//')'
!             write(*,*)'tqgetv 6: ',mjj,statevar(1:len_trim(statevar))
             call get_many_svar(statevar,values,mjj,n3,encoded,ceq)
! this output gives the composition for all compsets of a phase sequentially
! but we want them in phase tuple order
             ics=noel()
             call sortinphtup(n3,ics,values)
          endif
       elseif(n2.lt.0) then
! this means all components in one phase
! NOTE in this case n1 is a phasetuple index
!          ics=mod(n1,10)
!          nph=n1/10
!          if(nph.eq.0 .or. ics.eq.0) then
!             write(*,*)'You must use extended phase index'
!             gx%bmperr=8887; goto 1000
!          endif
!          call get_phase_name(nph,ics,name)
          write(*,*)'Phase : ',phcs(n1)%phase,phcs(n1)%compset
          call get_phase_name(phcs(n1)%phase,phcs(n1)%compset,name)
          if(gx%bmperr.ne.0) goto 1000
! added for composition sets
!          if(ics.gt.1) then
!             name=name//'#'//char(ichar('0')+ics)
!          endif
          statevar=stavar(1:1)//'('//name(1:len_trim(name))//',*) '
!          write(*,*)'tqgetv 7: ',mjj,statevar(1:len_trim(statevar))
          call get_many_svar(statevar,values,mjj,n3,encoded,ceq)
       else
! one component (n2) of one phase (n1)
! NOTE in this case n1 is 10*phase number + composition set number
!          ics=mod(n1,10)
!          nph=n1/10
!          if(nph.eq.0 .or. ics.eq.0) then
!             write(*,*)'You must use extended phase index'
!             gx%bmperr=8887; goto 1000
!          endif
!          call get_phase_name(nph,ics,name)
          call get_phase_name(phcs(n1)%phase,phcs(n1)%compset,name)
          if(gx%bmperr.ne.0) goto 1000
          statevar=stavar(1:1)//'('//name(1:len_trim(name))//','
          call get_component_name(n2,name,ceq)
          if(gx%bmperr.ne.0) goto 1000
          statevar(len_trim(statevar)+1:)=name(1:len_trim(name))//') '
!          write(*,*)'tqgetv 8: ',statevar
          call get_state_var_value(statevar,values(1),encoded,ceq)
       endif
!--------------------------------------------------------------------
! volume
    case('V   ')
       if(norm(1:1).ne.' ') then
          statevar='V'//norm
          ki=2
       else
          statevar='V '
          ki=1
       endif
       if(n1.gt.0) then
! Volume for a specific phase
! NOTE in this case n1 is 10*phase number + composition set number
!          ics=mod(n1,10)
!          nph=n1/10
!          if(nph.eq.0 .or. ics.eq.0) then
!             write(*,*)'You must use extended phase index'
!             gx%bmperr=8887; goto 1000
!          endif
!          call get_phase_name(nph,ics,name)
          call get_phase_name(phcs(n1)%phase,phcs(n1)%compset,name)
          if(gx%bmperr.ne.0) goto 1000
          statevar=statevar(1:ki)//'('//name(1:len_trim(name))//') '
!          call get_state_var_value(statevar,values(ics),encoded,ceq)
          call get_state_var_value(statevar,values(1),encoded,ceq)
          n3=1
       else
! Total volume
          call get_state_var_value(statevar,values(1),encoded,ceq)
          n3=1
       endif
!--------------------------------------------------------------------
! Gibbs energy
    case('G   ')
! phase specifier not allowed
       if(norm(1:1).ne.' ') then
          statevar='G'//norm
          ki=2
       else
          statevar='G '
          ki=1
       endif
!       write(*,*)'tqgetv 1: ',n1,ki
       if(n1.gt.0) then
! Gibbs energy for a specific phase
! NOTE in this case n1 is 10*phase number + composition set number
!          ics=mod(n1,10)
!          nph=n1/10
!          if(nph.eq.0 .or. ics.eq.0) then
!             write(*,*)'You must use extended phase index'
!             gx%bmperr=8887; goto 1000
!          endif
!          write(*,*)'tqgetv 2: ',nph,ics
!          call get_phase_name(nph,ics,name)
          call get_phase_name(phcs(n1)%phase,phcs(n1)%compset,name)
          if(gx%bmperr.ne.0) goto 1000
          statevar=statevar(1:ki)//'('//name(1:len_trim(name))//') '
!          write(*,*)'tqgetv 3: ',statevar
          call get_state_var_value(statevar,values(1),encoded,ceq)
          n3=1
       else
! Total Gibbs energy 
          call get_state_var_value(statevar,values(1),encoded,ceq)
          n3=1
       endif
!--------------------------------------------------------------------
! Mobilities
    case('MQ   ')
!       ics=mod(n1,10)
!       nph=n1/10
!       if(nph.eq.0 .or. ics.eq.0) then
!          write(*,*)'You must use extended phase index: 10*phase+compset'
!          gx%bmperr=8887; goto 1000
!       endif
!       call get_phase_name(nph,ics,name)
       call get_phase_name(phcs(n1)%phase,phcs(n1)%compset,name)
       if(gx%bmperr.ne.0) goto 1000
       statevar=stavar(1:len_trim(stavar))//'('//name(1:len_trim(name))//')'
!       write(*,*)'statevar: ',statevar
       call get_state_var_value(statevar,values(1),encoded,ceq)
!--------------------------------------------------------------------
! Second derivatives of the Gibbs energy of a phase
    case('D2G   ')
!       ics=mod(n1,10)
!       nph=n1/10
!       if(nph.eq.0 .or. ics.eq.0) then
!          write(*,*)'You must use extended phase index: 10*phase+compset'
!          gx%bmperr=8887; goto 1000
!       endif
!       write(*,*)'D2G 1: ',nph,ics
!       call get_phase_compset(nph,ics,lokph,lokcs)
       call get_phase_compset(phcs(n1)%phase,phcs(n1)%compset,lokph,lokcs)
       if(gx%bmperr.ne.0) goto 1000
!       write(*,*)'D2G 2: ',lokph,lokcs
! this gives wrong value!!
!       n3=ceq%phase_varres(lokcs)%ncc
       n3=size(ceq%phase_varres(lokcs)%yfr)
!       write(*,*)'D2G 3: ',n3
       kj=(n3*(n3+1))/2
!       write(*,*)'D2G 3: ',kj
       do ki=1,kj
          values(ki)=ceq%phase_varres(lokcs)%d2gval(ki,1)
       enddo
    end select
!===========================================================================
1000 continue
    return
  end subroutine tqgetv

!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\!/!!\

end MODULE LIBOCTQ

