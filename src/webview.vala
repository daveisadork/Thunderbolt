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
using WebKit;

class Thunderbolt.BrowserView : WebView {
	//public signal bool print_requested (WebFrame web_frame);
	public string? hovered_uri;
	
	public BrowserView () {
		this.settings.set_property("enable-developer-extras", true);
		this.populate_popup.connect(this.on_populate_popup);
		this.hovering_over_link.connect(this.on_hovering_over_link);
		hovered_uri = null;
	}

	public void on_hovering_over_link (WebView web_view, string? title, string? uri) {
		this.hovered_uri = uri;
	}
	
	public void on_populate_popup (WebKit.WebView web_view, Menu menu) {
		print("Populate popup\n");
		BrowserWindow window = (BrowserWindow) this.get_toplevel();
		if (this.hovered_uri == null) {
			SeparatorMenuItem sep = new SeparatorMenuItem();
			MenuItem save = new MenuItem.with_label ("Save as...");
			MenuItem print = new MenuItem.with_label ("Print...");
			MenuItem source = new MenuItem.with_label ("View Page Source");
			MenuItem info = new MenuItem.with_label ("View Page Info");
/*			List children = menu.get_children ();
			unowned List<MenuItem> inspector = (List<MenuItem>) children.last();
			*/
			menu.insert(sep, 4);
			menu.insert(save, 5);
			menu.insert(print, 6);
			menu.insert(source, 7);
			menu.insert(info, 8);
			source.activate.connect((widget) => {
				window.tabbed_browser.new_tab(this.uri, true, true);
			});
			print.activate.connect((widget) => {
				WebFrame frame = this.get_main_frame();
				this.print_requested(frame);
		/*		PrintOperation print_operation = new PrintOperation();
				frame.print_full(print_operation, PrintOperationAction.PRINT_DIALOG);*/
			});
/*			menu.reorder_child (inspector.prev.data, -1);
			menu.reorder_child (inspector.data, -1);*/
		} else {
			MenuItem new_tab = new MenuItem.with_label ("Open Link in New Tab");
			menu.insert (new_tab, 1);
			new_tab.activate.connect((widget) => {
				window.tabbed_browser.new_tab(this.hovered_uri, true);
			});
		}
		menu.show_all();
	}
}
