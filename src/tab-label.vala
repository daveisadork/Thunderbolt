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

class Thunderbolt.CloseTabButton : Button {
	private Image icon;
	private CssProvider provider;

	public CloseTabButton() {
		string style = """* {
			-GtkButton-default-border : 0;
			-GtkButton-default-outside-border : 0;
			-GtkButton-inner-border: 0;
			-GtkWidget-focus-line-width : 0;
			-GtkWidget-focus-padding : 0;
			padding: 0;
			}""";
		provider = new CssProvider();
		try {
			provider.load_from_data(style, style.length);
		} catch (Error e) {
			//print(@"e.message\n");
		}
		StyleContext context = this.get_style_context();
		context.add_provider(provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
		icon = new Image.from_stock(Stock.CLOSE, IconSize.MENU);
		this.set_image(icon);
		this.set_relief(ReliefStyle.NONE);
		this.set_focus_on_click(false);
		this.set_alignment(1.0f, 1.0f);
	}
}

class Thunderbolt.TabTitle : Label {
	private FontDescription font_desc;

	public TabTitle() {
		font_desc = FontDescription.from_string("9.5");
		this.modify_font(font_desc);
		this.set_ellipsize(EllipsizeMode.END);
		this.set_alignment(0.0f, 1.0f);
	}
}

class Thunderbolt.TabLabel : HBox {

	public CloseTabButton close_button;
	private TabTitle title;
	public Spinner spinner;
	public Image icon;

	public TabLabel () {
		this.set_homogeneous(false);
		this.set_spacing(2);
		this.set_vexpand(false);
		this.set_hexpand(false);
		this.set_can_focus (false);

		title = new TabTitle();
		icon = new Image.from_stock(Stock.FILE, IconSize.MENU);
		icon.set_can_focus(true);
		icon.set_alignment(0.0f, 1.0f);

		spinner = new Spinner();
		spinner.can_focus = false;
		spinner.set_size_request(16, 16);
		spinner.no_show_all = true;

		close_button = new CloseTabButton();
		this.pack_start(spinner, false, false, 0);
		this.pack_start(icon, false, false, 0);
		this.pack_start(title, true, true, 0);
		this.pack_start(close_button, false, false, 0);
		//this.set_data("label", self.title);
		//this.set_data("close-button", self.close_button);
		this.style_updated.connect(this.on_style_updated);

		spinner.show.connect(this.on_spinner_show);
		icon.show.connect(this.on_icon_show);

		this.set_size_request(165, 0);
		this.show_all ();
	}

	public void set_loading(bool loading) {
		if (loading) {
			this.spinner.show ();
		} else {
			this.icon.show ();
		}
	}

	private void on_spinner_show() {
		this.spinner.start ();
		this.icon.hide ();
	}

	private void on_icon_show() {
		this.spinner.hide ();
		this.spinner.stop ();
	}

	public void set_title(string? title) {
		this.title.set_text(title);
	}

	public void set_icon(Pixbuf? pixbuf) {
		if (pixbuf == null) {
			this.icon.set_from_stock (Stock.FILE, IconSize.MENU);
		} else {
			this.icon.set_from_pixbuf(pixbuf);
		}
	}
	
	private void on_style_updated() {
/*		var context = this.get_pango_context();
		var style = this.get_style();
		var language = context.get_language();
		var metrics = context.get_metrics(style.font_desc, language);
		var char_width = metrics.get_approximate_digit_width();
		var width = (((int)(char_width) + 512) >> 10);*/
		//this.set_size_request(165, 0);
	}

}