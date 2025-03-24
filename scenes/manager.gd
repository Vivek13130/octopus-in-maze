extends Node


var path_of_player := [] 
var reached_exit : bool = false 

var cell_size

var show_path_traveled : bool = false 
var leave_residue : bool = false  
var grid_size : int  

const min_grid_size = 3 
const max_grid_size = 50

var total_time : float = 0
