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

using Gtk;
using Gdk;

class Thunderbolt.BrowserMenu : Menu {
	public MenuItem new_tab;
	public MenuItem new_window;
	public MenuItem save;
	public MenuItem find;
	public MenuItem print_page;
	public SeparatorMenuItem menu_sep1;
	public SeparatorMenuItem menu_sep2;
	public MenuItem quit;

	public BrowserMenu (AccelGroup accel_group) {
		this.accel_group = accel_group;
		this.set_accel_group (accel_group);
		new_tab = new MenuItem.with_label ("New Tab");
		new_window = new MenuItem.with_label ("New Window");
		menu_sep1 = new SeparatorMenuItem();
		save = new MenuItem.with_label ("Save Page As...");
		find = new MenuItem.with_label ("Find...");
		print_page = new MenuItem.with_label ("Print...");
		menu_sep2 = new SeparatorMenuItem();
		quit = new MenuItem.with_label ("Quit");
		this.add(new_tab);
		this.add(new_window);
		this.add(menu_sep1);
		this.add(save);
		this.add(find);
		this.add(print_page);
		this.add(menu_sep2);
		this.add(quit);
		this.set_accel_path ("<ThunderboltTab>/Menu");
		this.show_all ();
	}
}