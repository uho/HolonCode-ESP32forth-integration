# Copyright (c) 2008 - 2021 Wolf Wejgaard. All  Rights Reserved.
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

proc SetDBLayout {} {
	mk::view layout wdb.base \
		{list active delchapters delsections delunits monitor view \
		 version changes geometry extension textcolor codecolor bonus \
		 pages forward comdel runcmd syntax safe fontsize running \
		 pagesize start revpage codefont codesize} 
	mk::view layout wdb.pages \
		{name page date:I who type next list active cursor source text \
		 changes old compcode test mode}
	mk::view layout wdb.archive {name date:I who id:I version}
	mk::view layout wdb.oldpages {link text source type test name}
}

proc CreateStructure {} {
		mk::row append wdb.base  monitor 0  view list	 version 0.001 \
			geometry "1100x700+50+50"  extension 1  \
			textcolor #ffffff  codecolor 1 pages 2 comdel //  running 0 \
			runcmd "../tclkit ./main.tcl"  syntax Tcl  safe 0 \
			pagesize A4  start 0  codefont Verdana  codesize 12  revpage 1
		set c [AppendPage type chapter  name "Revisions"  mode source]
    		SetBase list $c active $c
    		SetPage $c next ""
    		set s [AppendPage type section  name "Section"]
    		SetPage $c list $s active $s
    		SetPage $s next $c
    		set u [AppendPage type unit  name "0.001"]
    		SetPage $s list $u active $u
    		SetPage $u next $s
    		SetBase revpage $u
		mk::file commit wdb
}

proc UpdateRunning {} {
	SetBase running [clock seconds]
 	mk::file commit wdb
	after 60000 UpdateRunning
}

proc ProjectDB {} {
	global argv appname 
	set db [lindex $argv 0]
	set db "./$db"  
	set appname [file rootname [file tail $db]]
	return $db
}

proc OpenDB {} {
	global wdb db
	set db [ProjectDB]
	# open or create DB  
	set newdb [expr ![file exists $db]]
	mk::file open wdb $db -shared                 ;# wdb is handle of the db-file
	SetDBLayout
	if {$newdb} {CreateStructure}
	catch {
		if {[GetBase running]!="" && ([clock seconds]-[GetBase running])<10} {
			wm iconify .  ;# reduce window to icon, only message box is visible
			tk_messageBox -type ok -message "System is already running"
			exit
		}	
	}	
	UpdateRunning
}

proc CloseDB {} { 
	global wdb 
	SaveText
	after cancel UpdateRunning
	SetBase running 0 
	mk::file commit wdb 	
	mk::file close wdb
}

proc GetBase {field} {
	mk::get wdb.base!0 $field
}

proc SetBase {args} {
	eval mk::set wdb.base!0 $args
}

proc Chapter {} {
     GetBase active
}

proc SetChapter {c} {
     SetBase active $c
}

proc FirstChapter {} {
	GetBase list
}

proc NextChapter {} {
	Next [Chapter]
}

proc PrevChapter {} {
	set c [FirstChapter]
	if {$c==[Chapter]} {return ""}
	while {[Next $c]!=[Chapter]} {
		set c [Next $c]
	}
	return $c
}

proc NoChapters {} {
     expr {[GetBase list]==""}
}

proc GetChapter {r} {
	while {[GetPage $r type] == "section"} {
		set r [Next $r]
	}
	return $r
}

proc Section {} {
	GetPage [Chapter] active
}

proc SetSection {s} {
     SetPage [Chapter] active $s
}

proc FirstSection {} {
	GetPage [Chapter] list
}

proc NextSection {} {
	Next [Section]
}

proc PrevSection {} {
	set s [FirstSection]
	if {$s==[Section]} {return [Chapter]}
	while {[Next $s]!=[Section]} {
		set s [Next $s]
	}
	return $s
}

proc LastSection {} {
	set s [FirstSection]
	while {[Next $s]!=[Chapter]} {
		set s [Next $s]
	}
	return $s
}

proc NoSections {} {
     expr {[GetPage [Chapter] list]==[Chapter]}
}

proc GetSection {r} {
	while {[GetPage $r type] == "unit"} {
		set r [Next $r]
	}
	return $r
}

proc Unit {} {
     GetPage [Section] active
}

proc FirstUnit {} {
	GetPage [Section] list
}

proc NextUnit {} {
	Next [Unit]
}

proc PrevUnit {} {
	set u [FirstUnit]
	if {$u==[Unit]} {return [Section]}
	while {[Next $u]!=[Unit]} {
		set u [Next $u]
	}
	return $u
}

proc LastUnit {} {
	set u [FirstUnit]
	while {[Next $u]!=[Section]} {
		set u [Next $u]
	}	
	return $u
}

proc SetUnit {u} {
     SetPage [Section] active $u
}

proc NoUnits {} {
     expr {[GetPage [Section] list]==[Section]}
}

proc GetUnit {name} {
	regsub -all {[][?*\\]} $name \\\\& wordEscaped   
	set ids [mk::select wdb.pages -globnc name $wordEscaped type unit]
	set id [lindex $ids end]
	if {$id==""} {set id 0}
	return $id
}

proc pagevars {id args} {
	if {[llength $args] == 1} {
		uplevel 1 [list set $args [mk::get wdb.pages!$id $args]]
	} else {
		foreach x $args y [eval mk::get wdb.pages!$id $args] {
			uplevel 1 [list set $x $y]
		}
 	}
}

proc AppendPage {args} {
	set r [eval mk::row append wdb.pages $args]
	return [mk::cursor position r]
}

proc GetPage {i field} {
	mk::get wdb.pages!$i $field
}

proc SetPage {i args} {
	eval mk::set wdb.pages!$i $args
}

proc GetOldPage {i field} {
	mk::get wdb.oldpages!$i $field
}

proc Next {id} {
	GetPage $id next
}

proc Deleted {id} {
	if {[GetPage $id type]=="deleted"} {return 1} {return 0}
}

proc SavePage {id text code who newName cursor test changed} {
	global infomode version
  	pagevars $id name page source type 
   	if {$newName != $name} {
   		SetPage $id name $newName
  	}
  	if {$changed==1} {
    		SetPage $id date [clock seconds]
    		AddHistory $id; 
    		if {$infomode=="revisions"} {after 300 ShowRevisions}
    		if {$infomode=="revision"} {after 300 ShowRevision $version}
  	}
  	if {$type!="chapter"} {
  		SetPage $id source $code who $who cursor $cursor text $text test $test
	} {
		SetPage $id source $code who $who cursor $cursor text $text
	}
 	mk::file commit wdb
}

set page 0

proc CurrentPage {} {
	return $::page

}

proc PageStack {} {
	GetBase pages
}

proc SetPageStack {list} {
	SetBase pages $list
}

set maxPages 30

proc PushPage {page} { 
	SetPageStack [linsert [PageStack] 0 $page]
	if {[llength [PageStack]]>$::maxPages} {SetPageStack [lreplace [PageStack] $::maxPages end]}
	RemoveDoublePages
	set ::back 1
	ShowVisitedPages
}

proc RemoveDoublePages {} {
	set top [CurrentPage]
	set list $top
	foreach page [PageStack] {
		if {$page != $top} {lappend list $page}
	}	
	SetPageStack $list
}

set visitDelay 0

set visited 1500

proc StartVisitTime {} {
	if {$::visitDelay!=0} {after cancel $::visitDelay} 
	set ::visitDelay [after $::visited EndVisitTime]
}

proc EndVisitTime {} {
	set ::visitDelay 0 
	PushPage [CurrentPage]
}

set version 0

set oldVersion 0

proc SetVersion {v} {
	global version
	set version $v
	SetBase version $v
}

proc AddHistory {id} {
  	pagevars $id date page who name
  	mk::row append wdb.archive id $id name $name date $date who $who version $::version
}

proc osx {} {
	if {$::tcl_platform(os)=="Darwin"} {return true} {return false}
}

set RightButton Button-3   ;# Windows and Linux
if [osx] {set RightButton ButtonRelease-2}

if {$tcl_platform(os)=="Linux"} {tk scaling 1.2}

proc char {ascii} {
	format %c $ascii
}

proc ascii {c} {
	binary scan $c "c" a
	return $a
}

proc GetAscii {i} {
	global comp
	ascii [string index $comp(source) $i]
}

