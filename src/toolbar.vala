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

class Thunderbolt.AddressBar : Entry {
	Border border;

	public AddressBar () {
		this.set_icon_from_icon_name(EntryIconPosition.PRIMARY,
		                             "applications-internet");
		border = new Border();
		border.left = 2;
		this.set_inner_border(border);
	}
}

class Thunderbolt.Toolbar : Gtk.Toolbar {
	public ToolButton back_button;
	public ToolButton forward_button;
	public ToolButton stop_button;
	public ToolButton refresh_button;
	public AddressBar address_bar;
	public ToggleToolButton menu_button;
	public BrowserMenu menu;
	ToolItem entry_item;
	CssProvider provider;
	AccelGroup accel_group;

	public Toolbar (AccelGroup accel_group) {
		
		this.accel_group = accel_group;
		StyleContext style_context = this.get_style_context();
		style_context.add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
		string style = """* {
			GtkToolbar-internal-padding: 2;
			padding: 0;
			}""";
		provider = new CssProvider();
		try {
			provider.load_from_data(style, style.length);
		} catch (Error e) {
			print(e.message);
		}
		style_context.add_provider(provider,
		                           STYLE_PROVIDER_PRIORITY_APPLICATION);
		this.set_icon_size(IconSize.MENU);

		back_button = new ToolButton.from_stock(Stock.GO_BACK);
		back_button.set_state(StateType.INSENSITIVE);
		back_button.set_can_focus (false);
		this.add(back_button);

		forward_button = new ToolButton.from_stock(Stock.GO_FORWARD);
		forward_button.set_state(StateType.INSENSITIVE);
		forward_button.set_can_focus (false);
		this.add(forward_button);

		refresh_button = new ToolButton.from_stock(Stock.REFRESH);
		refresh_button.show.connect(this.on_refresh_button_show);
		refresh_button.set_can_focus (false);
		this.add(refresh_button);
		refresh_button.set_no_show_all(true);

		stop_button = new ToolButton.from_stock(Stock.STOP);
		stop_button.show.connect(this.on_stop_button_show);
		stop_button.set_can_default (false);
		this.add(stop_button);
		stop_button.set_no_show_all(true);

		address_bar = new AddressBar();
		entry_item = new ToolItem();
		entry_item.set_expand(true);
		entry_item.add(address_bar);
		this.add(entry_item);

		menu_button = new ToggleToolButton.from_stock(Stock.PROPERTIES);
		menu_button.set_label("Menu");
		menu_button.set_can_focus (false);
		this.add(menu_button);
		
		this.address_bar.add_accelerator("grab-focus", accel_group,
		                            keyval_from_name("l"),
		                            ModifierType.CONTROL_MASK,
		                            AccelFlags.VISIBLE);
		this.refresh_button.add_accelerator("clicked", accel_group,
		                               keyval_from_name("r"),
		                               ModifierType.CONTROL_MASK,
		                               AccelFlags.VISIBLE);
		this.refresh_button.add_accelerator("clicked", accel_group,
		                               keyval_from_name("F5"), 0,
		                               AccelFlags.VISIBLE);
		refresh_button.show();
	}

	public void connect_menu (BrowserMenu menu) {
		this.menu = menu;
		this.menu_button.clicked.connect(this.on_menu_button_clicked);
		this.menu.deactivate.connect (this.on_menu_deactivate);
	}

	public void on_menu_deactivate() {
		this.menu_button.set_active (false);
	}

	public void on_menu_button_clicked (ToolButton widget) {
		ToggleToolButton button = (ToggleToolButton) widget;
		if (button.active) {
			this.menu.popup(null, null, null, 0, Gdk.CURRENT_TIME);
		}
		
	}

	public void position_menu(Widget widget,
	                          out int out_x,
	                          out int out_y,
	                          bool push_in) {
		//if (!this.menu.get_realized()) this.menu.realize();
		print("Creating button allocation\n");
		Allocation ballocation;
		print("Creating menu allocation\n");
		Allocation mallocation;
		print("Getting button allocation\n");
		this.menu_button.get_allocation(out ballocation);
		print("Getting menu allocation\n");
		this.menu.get_allocation(out mallocation);
		print(@"button x: $(ballocation.x), button y: $(ballocation.y)\n");
		print(@"menu x: $(mallocation.x), menu y: $(mallocation.y)\n");
		print("Getting parent window\n");
		Gdk.Window window = this.get_parent_window();
		print("Getting root coordinates\n");
		int x;
		int y;
		window.get_root_coords(ballocation.x, ballocation.y, out x, out y);
		print("Setting outputs\n");
		out_x = x - mallocation.width + ballocation.width;
		out_y = y + ballocation.height + 2;
		print(@"x: $out_x, y: $out_y\n");
	}

	private void on_refresh_button_show() {
		this.stop_button.hide();
	}

	private void on_stop_button_show() {
		this.refresh_button.hide();
	}

	public void set_loading(bool loading) {
		if (loading) {
			this.stop_button.show();
		} else {
			this.refresh_button.show();
		}
	}

	public void update_progress(double progress) {
		this.address_bar.set_progress_fraction(progress);
		if (progress == 1.0) this.address_bar.set_progress_fraction(0.0);
	}
}
