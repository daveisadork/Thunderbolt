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
using WebKit;
using Soup;


class Thunderbolt.BrowserTab : VBox {
	public signal void open_in_new_tab(string url);
	public signal void title_changed(string? title);
	public string title;
	public Thunderbolt.Toolbar toolbar;
	public WebView web_view;
	public FindBar find_bar;
	public TabLabel label;
	Regex view_source;
	ScrolledWindow web_view_scrolled_window;
	AccelGroup accel_group;
	Cache cache;

	public BrowserTab (string? url=null, bool source=false) {
		if (url == null) {
			title = "New Tab";
		} else {
			title = url;
		}
		accel_group = new AccelGroup();
		toolbar = new Thunderbolt.Toolbar(accel_group);
		toolbar.set_can_focus (false);
		toolbar.refresh_button.clicked.connect(this.refresh);
		toolbar.back_button.clicked.connect(this.go_back);
		toolbar.forward_button.clicked.connect(this.go_forward);
		toolbar.stop_button.clicked.connect(this.stop_loading);
		toolbar.address_bar.activate.connect(this.on_address_bar_activate);
		web_view = new BrowserView();
		web_view.set_view_source_mode(source);
		web_view_scrolled_window = new ScrolledWindow(null, null);
		web_view_scrolled_window.add(web_view);
		//self.web_view.connect("hovering-over-link", self._hovering_over_link_cb);
		web_view.navigation_policy_decision_requested.connect(this.on_navigation_requested);
		web_view.new_window_policy_decision_requested.connect(this.on_navigation_requested);
		web_view.mime_type_policy_decision_requested.connect(this.on_mimetype_requested);
		web_view.create_web_view.connect(this.on_create_web_view);
		//self.web_view.connect("populate-popup", self._populate_page_popup_cb);
		web_view.title_changed.connect(this.on_title_changed);
		web_view.icon_loaded.connect(this.on_icon_loaded);
		web_view.console_message.connect(this.on_console_message);
		web_view.print_requested.connect(this.on_print_requested);
		web_view.notify["load-status"].connect(this.on_load_status_notify);
		web_view.notify["progress"].connect(this.on_progress_notify);
		find_bar = new FindBar();
		find_bar.find.connect(this.on_find_bar_find);
		label = new TabLabel();
		label.set_title (title);
		this.title_changed (title);
		if (url != null) {
			web_view.load_uri(url);
			toolbar.address_bar.set_text(url);
		}
		toolbar.back_button.sensitive = web_view.can_go_back();
		toolbar.forward_button.sensitive = web_view.can_go_forward();

		
		toolbar.address_bar.copy_clipboard.connect_after(this.on_copy_clipboard);
		toolbar.address_bar.cut_clipboard.connect_after(this.on_copy_clipboard);
		this.pack_start(toolbar, false, false, 0);
		this.pack_start(web_view_scrolled_window, true, true, 0);
		this.pack_start(find_bar, false, false, 0);
		label.close_button.add_accelerator("clicked", accel_group,
		                                   keyval_from_name("F4"),
		                                   ModifierType.CONTROL_MASK,
		                                   AccelFlags.VISIBLE);
		cache = new Cache();
		this.show.connect(this.on_show);
		view_source = /^view-source:/i;
	}

	public bool on_print_requested (WebView? web_view = null, WebFrame? web_frame = null) {
		if (web_frame == null) web_frame = this.web_view.get_main_frame();
		PrintOperation print_operation = new PrintOperation();
		web_frame.print_full(print_operation, PrintOperationAction.PRINT_DIALOG);
		return true;
	}

	public WebView on_create_web_view(WebView web_view, WebFrame web_frame) {
		BrowserWindow new_window = new BrowserWindow();
		Gtk.Window window = (Gtk.Window) this.get_toplevel ();
		Gtk.Application app = window.get_application();
		new_window.tabbed_browser.new_tab();
		BrowserTab tab = (BrowserTab) new_window.tabbed_browser.get_nth_page(0);
		app.add_window(new_window);
		return tab.web_view;
	}

	public void on_copy_clipboard (Entry entry) {
		Clipboard clipboard = Clipboard.get (SELECTION_CLIPBOARD);
		clipboard.set_text (this.web_view.get_uri(), -1);
	}

	public void show_find_bar () {
		this.find_bar.show_all();
		this.find_bar.entry.grab_focus();
	}

	public void on_show () {
		BrowserWindow window = (BrowserWindow) this.get_toplevel ();
		window.add_accel_group(this.accel_group);
		this.find_bar.hide();
	}

	public bool on_find_bar_find (FindBar find_bar,
	                              string? text,
	                              bool case_sensitive,
	                              bool forward,
	                              bool wrap) {
		bool success;
		this.web_view.set_highlight_text_matches (false);
		this.web_view.unmark_text_matches ();
		if (text == null || text == "") {
			success = true;
		} else {
			success = this.web_view.search_text(text, false, true, true);
		}
		if (success) {
			uint n_matches = this.web_view.mark_text_matches(text, false, 0);
			print(@"$n_matches matches\n");
			this.web_view.set_highlight_text_matches (true);
		} else {
			this.web_view.unmark_text_matches();
		}
		return success;
	}
	
	public void on_load_status_notify () {
		switch (this.web_view.load_status) {
			case LoadStatus.PROVISIONAL:
				this.set_loading(true);
				break;
			case LoadStatus.COMMITTED:
				this.on_load_committed();
				break;
			case LoadStatus.FINISHED:
				this.set_loading(false);
				break;
			case LoadStatus.FIRST_VISUALLY_NON_EMPTY_LAYOUT:
				//print("load first visually non-empty layout\n");
				break;
			case LoadStatus.FAILED:
				this.set_loading (false);
				break;
		}
	}

	public void refresh() {
		this.web_view.reload();
	}

	public void go_forward() {
		this.web_view.go_forward();
	}

	public void go_back() {
		this.web_view.go_back();
	}

	public void stop_loading() {
		this.web_view.stop_loading();
		this.toolbar.set_loading(false);
		this.label.set_loading(false);
	}

	public void on_address_bar_activate() {
		string text = this.toolbar.address_bar.get_text();
		this.web_view.set_view_source_mode(view_source.match(text));
		if (view_source.match(text)) {
			try {
				text = view_source.replace(text, -1, 0, "");
			} catch (RegexError e) {
				//print(@"$(e.message)\n");
			}
		}
		if (text != "") {
			this.web_view.grab_focus();
			string uri = Utils.get_uri(text);
			this.set_title (uri);
			this.web_view.load_uri(uri);
		}
	}

	public bool on_console_message(WebView web_view,
	                               string message,
	                               int line,
	                               string source_id) {
		return true;
	}

	public bool on_mimetype_requested(WebView web_view,
	                                  WebFrame web_frame,
	                                  NetworkRequest request,
	                                  string mime_type,
	                                  WebPolicyDecision decision) {
		string uri = request.get_uri();
		if (uri == "about:blank") {
			return false;
		}
		bool can_show = web_view.can_show_mime_type(mime_type);
		string disposition = "";
		Message message = request.get_message();
		unowned MessageHeaders headers = message.response_headers;
		bool has_disposition;
		has_disposition = headers.get_content_disposition(out disposition,
		                                                  null);
		if (has_disposition && disposition == "attachment") {
			decision.download();
			return true;
		} else if (can_show) {
			return false;
		} else {
			decision.download();
			return true;
		}
	}

	public bool on_navigation_requested(WebView web_view,
										WebFrame web_frame,
										NetworkRequest request,
										WebNavigationAction action,
										WebPolicyDecision decision) {
		int button = action.get_button();
		if (button == 2) {
			decision.ignore();
			string url = action.get_original_uri();
			this.open_in_new_tab(url);
			return true;
		} else {
			return false;
		}
	}

	public void on_icon_loaded(WebView web_view, string? uri_string) {
		URI uri = new URI(uri_string);
		string filename = @"$(this.cache.FAVICONS)/$(uri.host)_$(uri.port).ico";
		File file = File.new_for_path (filename);
		if (file.query_exists ()) {
			try {
				Pixbuf pixbuf = new Pixbuf.from_file_at_scale (filename, 16,
				                                               16, true);
				this.label.set_icon (pixbuf);
			} catch (Error e) {
				//print(@"e.message\n");
				try {
					file.delete (null);
				} catch (Error e) {
					//print(@"e.message\n");
				}
			}
		}
		if (!file.query_exists ()) {
			this.label.set_icon(null);
			Session session = get_default_session();
			Message message = new Message.from_uri("GET", uri);
			session.queue_message(message, this.on_icon_downloaded);
		}
	}

	public void on_icon_downloaded(Session session, Message message) {
		unowned MessageBody body = message.response_body;
		MemoryInputStream stream = new MemoryInputStream.from_data(body.data,
		                                                           null);
		try {
			Pixbuf pixbuf = new Pixbuf.from_stream_at_scale(stream, 16, 16,
			                                                true, null);
			this.label.set_icon (pixbuf);
			try {
				unowned URI uri = message.get_uri();
				string filename = @"$(uri.host)_$(uri.port).ico";
				pixbuf.save (@"$(this.cache.FAVICONS)/$filename", "ico");
			} catch (Error e) {
				//print(@"e.message\n");
			}
		} catch (Error e) {
			this.label.set_icon (null);
			//print(@"e.message\n");
		}
	}

	public void set_title(string? title) {
		if (title == null) title = "New Tab";
		this.title = title;
		this.label.set_title(title);
		this.title_changed(title);
	}

	public void on_title_changed(WebView web_view,
	                             WebFrame web_frame,
	                             string? title) {
		this.set_title (title);
	}

	public void on_load_committed() {
		string uri = this.web_view.get_uri();
		string title = Utils.get_clean_url(uri);
		if (this.web_view.get_view_source_mode()) {
			title = @"view-source:$title";
		}
		this.toolbar.address_bar.set_text(title);
		this.title = title;
		this.label.set_title (title);
		this.toolbar.back_button.sensitive = this.web_view.can_go_back();
		this.toolbar.forward_button.sensitive = this.web_view.can_go_forward();
	}

	public void on_progress_notify() {
		this.toolbar.update_progress (this.web_view.progress);
	}

	public void set_loading(bool loading) {
		this.toolbar.set_loading(loading);
		this.label.set_loading(loading);
	}
}
