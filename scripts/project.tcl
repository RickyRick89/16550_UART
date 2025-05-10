################################################################
# Necessary Packages:

package require try
package require cmdline

################################################################
# Commandline Options:

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Options list:

set options {
  {project_name.arg         "unnamed_project"                                             "The name of the project."}
  {origin_dir.arg           "."                                                           "The origin directory of this project."}
  {script_name.arg          "project.tcl"                                                 "The name of this script."}
  {synth_source_list.arg    "none"                                                        "A list of sources for synthesis only."}
  {source_list.arg          "none"                                                        "A list of sources for synthesis and simulation."}
  {sim_source_list.arg      "none"                                                        "A list of sources for simulation only."}
  {block_designs.arg        "none"                                                        "A list of block designs to source."}
  {constraints.arg          "constraints.xdc"                                             "The constraint file for this project."}
  {ip_paths.arg             "none"                                                        "A list of paths to search for IP."}
  {top.arg                  "top"                                                         "The name of the top level module."}
  {sim_top.arg              "top"                                                         "The name of the top level simulation module."}
  {board_part_repo_path.arg "~/.Xilinx/Vivado/2023.1/xhub/board_store/xilinx_board_store" "The path to the board_part_repo."}
  {board_part.arg           "digilentinc.com:basys3:part0:1.2"                            "The board to target for this project."}
  {board_id.arg             "basys3"                                                      "The board's ID."}
  {part.arg                 "xc7a35tcpg236-1"                                             "The FPGA part to target for this project."}
}

set usage ": vivado source project.tcl -tclargs ,,,"

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Gather command line options:

try {
  array set params [::cmdline::getoptions argv $options $usage]
} trap {CMDLINE USAGE} {msg o} {
  puts $msg
  exit 1
}

set script_name $params(script_name)

################################################################
# Project Creation:

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the project:

create_project $params(project_name) "./$params(project_name)" -part $params(part)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set the directory:

set project_dir [get_property directory [current_project]]

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set up the project properties:

set obj [current_project]
set_property -name "board_part_repo_paths"       -value [file normalize $params(board_part_repo_path)] -objects $obj
set_property -name "board_part"                  -value $params(board_part)                            -objects $obj
set_property -name "platform.board_id"           -value $params(board_id)                              -objects $obj
set_property -name "default_lib"                 -value "xil_defaultlib"                               -objects $obj
set_property -name "revised_directory_structure" -value "1"                                            -objects $obj

################################################################
# Synthesis Source Importation:

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the sources_1 fileset if it doesn't exist:

if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set IP repository paths:

set obj [get_filesets sources_1]
if { $obj != {} } {
  if {$params(ip_paths) != "none" && $params(ip_paths) != "../none"} {
    set normalized_ip_paths ""

    foreach ip_path $params(ip_paths) {
      lappend normalized_ip_paths "[file normalize $ip_path]"
    }

    set_property "ip_repo_paths" $normalized_ip_paths $obj

    # Rebuild user ip_repo's index before adding any source files
    update_ip_catalog -rebuild
  }
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Add sources:

proc add_files_to_fileset {file_set source_files sim} {

  foreach source_file $source_files {

    add_files -norecurse -fileset $file_set [file normalize $source_file]

    if {$sim == "true"} {
      set_property used_in_simulation true  -objects [get_files -of_objects [get_filesets $file_set] [file normalize $source_file]]
    } else {
      set_property used_in_simulation false -objects [get_files -of_objects [get_filesets $file_set] [file normalize $source_file]]
    }

  }

}

if { [lindex $params(synth_source_list) 0] != "none" && [lindex $params(synth_source_list) 0] != "../none"} {

  add_files_to_fileset [get_filesets sources_1] $params(synth_source_list) "false"

}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Add source files to sources_1:

if { [lindex $params(source_list) 0] != "none" && [lindex $params(source_list) 0] != "../none"} {

  add_files_to_fileset [get_filesets sources_1] $params(source_list) "true"

}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set up the top for synthesis:

set obj [get_filesets sources_1]
set_property -name "top" -value $params(top) -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj

################################################################
# Constraint Importation:

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the constrs_1 fileset if it does not exist:
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Import constraint files:
set file [file normalize $params(constraints)]
add_files -norecurse -fileset $obj [list $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj

################################################################
# Simulation Source Importation:

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create the sim_1 fileset if it does not exist:

if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Add source files to sim_1:

if { [lindex $params(sim_source_list) 0] != "none" && [lindex $params(sim_source_list) 0] != "../none"} {

  add_files_to_fileset [get_filesets sim_1] $params(sim_source_list) "true"

}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set up the top for simulation:

set obj [get_filesets sim_1]
set_property -name "top" -value $params(sim_top) -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj

################################################################
# Create Block Designs:

if {$params(block_designs) != "none"} {
  foreach block_design $params(block_designs) {
    puts $block_design
  }
  foreach block_design $params(block_designs) {
    source $block_design
    close_bd_design $design_name
  }
}

################################################################
# Final Touches:

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Set the compilation order to automatic:
set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Ignore invalid top modules:
set_property source_mgmt_mode DisplayOnly [current_project]

exit
