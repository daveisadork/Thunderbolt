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

public class Thunderbolt.Main : Gtk.Application {

	Cache cache;

	public Main (string app_id, ApplicationFlags flags)
	{
		GLib.Object (application_id: app_id, flags: flags);
		this.startup.connect_after (this.after_startup);
		this.activate.connect (this.on_activate);
		this.open.connect (this.on_open);
	}

	public void after_startup () {
		Environment.set_application_name ("Thunderbolt");
		Environment.set_prgname ("Thunderbolt");
		this.cache = new Cache();
		BrowserWindow window = new BrowserWindow();
		this.add_window(window);
		File session;
		session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/prev_session");
		if (!session.query_exists (null)) {
			session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/curr_session");
			File crash_session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/crash_session");
			try {
				session.move(crash_session, FileCopyFlags.OVERWRITE, null, null);
			} catch (Error e) {
				//print(@"$(e.message)\n");
			}
		}
	}

	public void on_activate () {
		BrowserWindow active_window;
		Gtk.Window window;
		string window_type;
		unowned List windows = this.get_windows ();
		unowned List<Gtk.Window> item = (List<Gtk.Window>) windows.last ();
		window = (Gtk.Window) item.data;
		window_type = window.get_data("window-type");
		while (window_type != "browser" && item.prev != null) {
			item = item.prev;
			window = (Gtk.Window) item.data;
			window_type = window.get_data("window-type");
			print(@"$window_type\n");
		}
		if (window_type == "browser") {
			active_window = (BrowserWindow) window;
		} else {
			active_window = new BrowserWindow();
		}
		TabbedBrowser tabbed_browser = active_window.tabbed_browser;
		if (tabbed_browser.get_n_pages() == 0) {
			if (!tabbed_browser.restore_session()) {
				tabbed_browser.new_tab("http://www.duckduckgo.com/");
			}
		}
		active_window.present_with_time (Gdk.CURRENT_TIME);
	}

	public void on_open(GLib.Application app, File[] uris, string hint) {
		string uri;
		unowned List windows = this.get_windows();
		BrowserWindow window = (BrowserWindow) windows.last ().data;
		window.tabbed_browser.restore_session();
		for (int nth_uri = 0; nth_uri < uris.length; nth_uri++) {
			uri = Utils.get_uri(uris[nth_uri].get_uri());
			window.tabbed_browser.new_tab(uri, true);
		}
	}

	static int main (string[] argv) 
	{
		Thunderbolt.Main app;
		app = new Thunderbolt.Main ("org.gnome.Thunderbolt",
		                            ApplicationFlags.HANDLES_OPEN);
		int status = app.run (argv);
		return status;
	}
}
