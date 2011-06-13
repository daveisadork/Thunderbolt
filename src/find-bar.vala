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

class Thunderbolt.CloseFindBarButton : Button {

	private Image icon;
	private CssProvider provider;

	public CloseFindBarButton () {
		string style = """* {
			-GtkButton-default-border : 0;
			-GtkButton-default-outside-border : 0;
			-GtkButton-inner-border: 0;
			-GtkWidget-focus-line-width : 0;
			-GtkWidget-focus-padding : 0;
			padding: 4;
			}""";
		icon = new Image.from_stock(Stock.CLOSE, IconSize.MENU);
		provider = new CssProvider();
		try {
			provider.load_from_data(style, style.length);
		} catch (Error e) {
			print(e.message);
		}
		StyleContext context = this.get_style_context();
		context.add_provider(provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
		this.set_image(icon);
		this.set_relief(ReliefStyle.NONE);
		this.set_focus_on_click(false);
	}
}

class Thunderbolt.FindEntry : Entry {

	private Border border;
	public StyleContext style_context;

	public FindEntry () {
		border = new Border();
		border.left = 2;
		this.set_inner_border(border);
		style_context = this.get_style_context();
	}
}

class Thunderbolt.FindBar : HBox {
	public signal bool find (string? text = null,
	                         bool case_sensitive = false,
	                         bool forward = true,
	                         bool wrap = true);
	public CloseFindBarButton close_button;
	public Label label;
	public FindEntry entry;
	public Button back_button;
	public Button forward_button;
	public StyleContext style_context;

	public FindBar()
	{
		//this.no_show_all = true;
		this.set_border_width (4);
		style_context = this.get_style_context ();
		this.set_spacing (4);
		close_button = new CloseFindBarButton();
		label = new Label("Find:");
		entry = new FindEntry();
		back_button = new Button.from_stock (Stock.GO_BACK);
		forward_button = new Button.from_stock (Stock.GO_FORWARD);
		this.pack_start (close_button, false, false, 0);
		this.pack_start (label, false, false, 0);
		this.pack_start (entry, false, false, 0);
		this.pack_start (back_button, false, false, 0);
		this.pack_start (forward_button, false, false, 0);
		entry.notify["text"].connect(this.on_entry_text_notify);
		back_button.clicked.connect(this.on_back_button_clicked);
		forward_button.clicked.connect(this.on_forward_button_clicked);
		close_button.clicked.connect(this.on_close_button_clicked);
		this.show.connect(this.on_show);
	}

	public void on_show () {
		this.entry.grab_focus ();
	}

	public void on_close_button_clicked () {
		this.hide();
	}
	
	public void on_entry_text_notify () {
		bool status = this.find(this.entry.text, false, true, true);
		this.on_find(status);
	}

	public void on_back_button_clicked () {
		bool status = this.find(this.entry.text, false, false, true);
		this.on_find(status);
	}

	public void on_forward_button_clicked () {
		bool status = this.find(this.entry.text, false, true, true);
		this.on_find(status);
	}

	public void on_find (bool status) {
		if (status) {
			this.entry.style_context.remove_class(STYLE_CLASS_ERROR);
		} else {
			this.entry.style_context.add_class(STYLE_CLASS_ERROR);
		}
	}
}