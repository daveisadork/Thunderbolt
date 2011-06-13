/* -*- Mode: vala; tab-width: 4; intend-tabs-mode: t -*- */
/* thunderbolt
 *
 * Copyright (C) Dave Hayes 2011 <dwhayes@gmail.com>
 *
 * thunderbolt is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * thunderbolt is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using Gtk;
using Gdk;
using Pango;

/*class Gedit.Overlay {
	[CCode (has_construct_function = false)]
	[Import ()]
	public Overlay (Gtk.Widget main_widget, Gtk.Widget? relative_widget);
}*/

/*//[CCode (cprefix = "Gedit", lower_case_cprefix = "gedit_")]
namespace Thunderbolt.Gedit {
	[CCode (cprefix = "tunderbolt_overlay_", cheader_filename = "gedit-overlay.h")]
	public extern class Overlay : Gtk.Container {
		[CCode (has_construct_function = false)]
		public extern Overlay (Gtk.Widget main_widget, Gtk.Widget? relative_widget);
		extern void add (Gtk.Widget widget,
		                Gedit.Position position,
                        uint offset);
		extern void set_composited (bool enabled);

		//extern GLib.Type get_type ();
		
	}

	[CCode (cprefix = "tunderbolt_overlay_child_", cheader_filename = "gedit-overlay-child.h")]
	public extern class OverlayChild : Gtk.Bin {
		[CCode (has_construct_function = false)]
		public extern OverlayChild (Gtk.Widget widget);
        extern Gedit.Position get_position ();
        extern void set_position (Gedit.Position position);
        extern uint get_offset ();
        extern void set_offset (uint offset);
        extern bool get_fixed ();
        extern void set_fixed (bool fixed);
		//extern GLib.Type get_type ();
		
	}
	//[CCode (cprefix = "GEDIT_OVERLAY_CHILD_POSITION_", cheader_filename = "gedit-overlay-child.h")]
	public enum Position {
	    NORTH_WEST,
	    NORTH,
	    NORTH_EAST,
	    WEST,
	    CENTER,
	    EAST,
	    SOUTH_WEST,
	    SOUTH,
	    SOUTH_EAST,
	    STATIC
	}
	
	    
//	[CCode (cheader_filename = "webkit/webkit.h")]
//	public static void set_web_database_directory_path (string path);
}*/