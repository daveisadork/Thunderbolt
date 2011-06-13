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

class Thunderbolt.BrowserWindow : Gtk.Window {
	public TabbedBrowser tabbed_browser;

	public BrowserWindow()
	{
		this.set_title("Thunderbolt");
		this.set_data ("window-type", "browser");
		this.set_default_size(1024, 768);
		this.set_default_icon_name ("weather-storm");
		tabbed_browser = new TabbedBrowser();
		this.add(tabbed_browser);
		tabbed_browser.title_changed.connect(this.on_title_changed);
		this.destroy.connect(this.on_destroy);
		this.show_all();
		this.setup_accel_map ();
	}

	public void on_destroy (Widget widget) {
		this.tabbed_browser.save_session(true);
	}

	public void on_title_changed(string? title) {
		string new_title = @"$title - Thunderbolt";
		this.set_title(new_title);
	}

	public void setup_accel_map () {
		AccelMap.add_entry ("<ThunderboltTab>/Menu/New Tab",
		                         keyval_from_name("t"),
		                         ModifierType.CONTROL_MASK);
		AccelMap.add_entry ("<ThunderboltTab>/Menu/New Window",
		                         keyval_from_name("n"),
		                         ModifierType.CONTROL_MASK);
		AccelMap.add_entry ("<ThunderboltTab>/Menu/Save Page As...",
		                           keyval_from_name("s"),
		                           ModifierType.CONTROL_MASK);
		AccelMap.add_entry ("<ThunderboltTab>/Menu/Find...",
		                           keyval_from_name("f"),
		                           ModifierType.CONTROL_MASK);
		AccelMap.add_entry ("<ThunderboltTab>/Menu/Print...",
		                           keyval_from_name("p"),
		                           ModifierType.CONTROL_MASK);
		AccelMap.add_entry ("<ThunderboltTab>/Menu/Quit",
		                           keyval_from_name("q"),
		                           ModifierType.CONTROL_MASK);
		Gtk.AccelMap.save ("/home/dhayes/Desktop/test.map");
	}

}