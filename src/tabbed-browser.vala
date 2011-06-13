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
using GnomeKeyring;

class Thunderbolt.NewTabButton : VBox {

	public Button button;
	private HBox hbox;
	private Image image;
	private CssProvider provider;

	public NewTabButton () {
		button = new Button();
		hbox = new HBox(false, 0);
		string style = """* {
			-GtkButton-default-border : 0;
			-GtkButton-default-outside-border : 0;
			-GtkButton-inner-border: 0;
			-GtkWidget-focus-line-width : 0;
			-GtkWidget-focus-padding : 0;
			padding: 4;
			}""";
		provider = new CssProvider();
		try {
			provider.load_from_data(style, style.length);
		} catch (Error e) {
			//print(@"e.message\n");
		}
		StyleContext context = button.get_style_context();
		context.add_provider(provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
		image = new Image.from_stock(Stock.ADD, IconSize.MENU);
		button.set_image(image);
		button.set_relief(ReliefStyle.NONE);
		button.set_focus_on_click(false);
		hbox.pack_start(button, false, false, 2);
		this.pack_start(hbox, false, false, 2);
	}
}

class Thunderbolt.TabbedBrowser : Notebook {
	public signal void title_changed(string? title);
	private NewTabButton new_tab_button;
	private CssProvider provider;
	public AccelGroup accel_group;
	public CookieJarText cookie_jar;
	public Cache cache;
	public BrowserMenu browser_menu;
	public BrowserTab active_tab;

	public TabbedBrowser () {
		Session soup_session = get_default_session();
		CacheModel cache_model = CacheModel.WEB_BROWSER;
		set_cache_model(cache_model);
		cache = new Cache();
		set_web_database_directory_path(cache.DATABASES);
		cookie_jar = new CookieJarText(cache.COOKIES, false);
		soup_session.add_feature = cookie_jar;
		soup_session.authenticate.connect(this.on_authenticate);
		
		string style = """
			.notebook {
				padding: 0;
				border-style: none;
				border-width: 0;
			}

			.notebook tab {
				padding: 2 2 0;
			}

			.notebook tab:active {
				padding: 1 2 0;
				border-width: 1;
			}""";
		provider = new CssProvider();
		try {
			provider.load_from_data(style, style.length);
		} catch (Error e) {
			//print(@"e.message\n");
		}
		StyleContext context = this.get_style_context();
		context.add_provider(provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
		this.set_scrollable(true);
		this.set_group_name("Thunderbolt Browser");
		new_tab_button = new NewTabButton();
		this.set_action_widget(new_tab_button, PackType.END);
		accel_group = new AccelGroup();
		browser_menu = new BrowserMenu(accel_group);
		browser_menu.find.activate.connect((widget) => {
			this.active_tab.show_find_bar();
		});
		browser_menu.new_window.activate.connect(this.on_new_window_activate);
		browser_menu.print_page.activate.connect((widget) => {
			this.active_tab.on_print_requested ();
		});
		browser_menu.new_tab.activate.connect((widget) => {
			this.new_tab (null, true);
		});
		browser_menu.quit.activate.connect((widget) => {
			Gtk.main_quit();
		});
		new_tab_button.button.clicked.connect((button) => {
			this.new_tab();
		});
		this.switch_page.connect_after((tab, page_num) => {
			this.on_tab_changed(tab, page_num);
		});
		//AsyncQueue closed_tabs = new AsyncQueue();
		new_tab_button.show_all();
		this.show.connect(this.on_show);
		this.size_allocate.connect(this.resize_tabs);
		//this.realize.connect(this.on_realize);
	}

	public void on_authenticate (Session session, Message message,
	                             Auth auth, bool retrying) {
		print(@"on_authenticate(retrying=$retrying)\n");
		if (!retrying) {
			auth.save_password.connect((auth, username, password) => {
				this.on_save_password(message, auth, username, password);
			});
		}
/*		auth.notify["is-authenticated"].connect((widget, property) => {
			this.on_save_password (message, auth);
		});*/
	}

	public void on_save_password(Message message, Auth auth,
	                             string? username = null,
	                             string? password = null) {
		URI uri = message.get_uri().copy();
		print(@"$(uri.to_string (false))\n");
		string server = uri.host;
		string protocol = uri.scheme;
		string domain = auth.realm;
		uint port = uri.port;
		if (username == null) username = uri.user;
		if (password == null) password = uri.password;
		uri.password = null;
		string display_name = uri.to_string(false);
		print(@"on_save_password(protocol=$protocol, username=$username, password=$password, server=$server, port=$port, domain=$domain)\n");
		store_password_sync (GnomeKeyring.NETWORK_PASSWORD,
		                                  null, display_name, password,
		                                  "server", server,
		                                  "protocol", protocol,
		                                  "domain", domain,
		                                  "port", port);
	}

	public void on_new_window_activate () {
		BrowserWindow new_window = new BrowserWindow();
		Gtk.Window window = (Gtk.Window) this.get_toplevel ();
		Gtk.Application app = window.get_application();
		new_window.tabbed_browser.new_tab("http://www.duckduckgo.com/");
		app.add_window(new_window);
	}
	
	public void save_session (bool shutdown = false) {
		File session;
		session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/curr_session");
		if (shutdown) {
			try {
				session.delete (null);
			} catch (Error e) {
				//print(@"$(e.message)\n");
			}
			session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/prev_session");
		}
		try {
			if (session.query_exists(null)) session.delete(null);
			FileOutputStream stream = session.create(FileCreateFlags.REPLACE_DESTINATION, null);
			string uri;
			for (int page = 0; page < this.get_n_pages(); page++) {
				BrowserTab tab = (BrowserTab) this.get_nth_page(page);
				uri = tab.web_view.uri;
				if (uri == null) {
					uri = "<New Tab>";
				}
				stream.write(@"$uri\n".data, null);
				if (shutdown) {
					tab.web_view.destroy();
					tab.toolbar.destroy();
					tab.find_bar.destroy();
					this.remove_page (page);
					page--;
				}
			}
		} catch (Error e) {
			//print(@"$(e.message)\n");
		}
	}
	
	public bool restore_session () {
	    File session;
		session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/crash_session");
		if (session.query_exists (null)) {
			Gtk.Window window = (Gtk.Window) this.get_toplevel ();
			Dialog crash_dialog;
			crash_dialog = new Dialog.with_buttons ("That wasn't supposed to happen...",
	                                               window,
			                                       DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT,
	                                               Stock.YES, ResponseType.ACCEPT,
	                                               Stock.NO, ResponseType.REJECT,
	                                               null);
			crash_dialog.set_border_width (5);
			crash_dialog.set_resizable (false);
			Box action_area = (Box) crash_dialog.get_action_area ();
			action_area.set_border_width(5);
			action_area.set_spacing(6);
			Box content = (Box) crash_dialog.get_content_area ();
			content.set_spacing (2);
			HBox message = new HBox(false, 10);
			message.set_border_width (8);
			Image image = new Image.from_stock (Stock.DIALOG_WARNING, IconSize.DIALOG);
			Label label = new Label("It looks like Thunderbolt may have crashed the last time it ran.\nWould you like to try to restore your session?");
			message.pack_start (image, false, false, 0);
			message.pack_start (label, false, false, 0);
			content.pack_start (message, false, false, 0);
			message.show_all();
			int response = crash_dialog.run();
			if (response != ResponseType.ACCEPT) {
				try {
					session.delete(null);
				} catch (Error e) {
					//print(@"$(e.message)\n");
				}
				session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/prev_session");
			}
			crash_dialog.destroy();
		} else {
			session = File.new_for_path (@"$(this.cache.BASE_DIRECTORY)/prev_session");
		}
		if (session.query_exists (null)) {
		    int n_pages = 0;
			try {
				DataInputStream stream = new DataInputStream(session.read (null));
				string url;
				while ((url = stream.read_line(null)) != null) {
					if (url == "<New Tab>") url = null;
					this.new_tab (url);
					n_pages++;
				}
			} catch (Error e) {
				//print(@"$(e.message)\n");
			} finally {
			    try {
				    session.delete (null);
				} catch (Error e) {
				    //print(@"$(e.message)\n");
			    }
			}
			if (n_pages == 0) {
			    return false;
			} else {
			    return true;
			}
		} else {
			return false;
		}
	}

	public void on_show() {
		BrowserWindow window = (BrowserWindow) this.get_toplevel ();
		window.add_accel_group(this.accel_group);
	}

	public void resize_tabs() {
/*		Widget first_tab = this.get_nth_page(0);
		Widget last_tab = this.get_nth_page(-1);
		TabLabel first_label = (TabLabel) this.get_tab_label (first_tab);
		TabLabel last_label = (TabLabel) this.get_tab_label (last_tab);
		print(@"First tab visible: $(first_label.visible)\n");
		print(@"Last tab visible: $(last_label.visible)\n");*/
		Allocation allocation;
		this.new_tab_button.get_allocation(out allocation);
		int tab_area_width = allocation.x;
		int width = 165;
		int n_pages = this.get_n_pages();
		int total_width = 0;
		bool resize = 185 * n_pages >= tab_area_width && tab_area_width != -1;
		if (resize) {
			width = tab_area_width / n_pages - 20;
/*			print(@"number of tabs: $n_pages\n");
			print(@"tab area width: $tab_area_width\n");
			print(@"tab width: $width\n");*/
		} 
		for (int page = 0; page < n_pages; page++) {
			Widget child = this.get_nth_page (page);
			TabLabel label = (TabLabel) this.get_tab_label (child);
			label.set_size_request(width, 0);
			total_width += width + 20;
		}
		while (resize && !(total_width > tab_area_width)) {
			for (int page = 0; page < n_pages; page++) {
				if (total_width > tab_area_width) break;
				Widget child = this.get_nth_page (page);
				TabLabel label = (TabLabel) this.get_tab_label (child);
				label.get_size_request(out width, null);
				width += 2;
				label.set_size_request(width, 0);
				total_width++;
			}
		}
	}

	public void new_tab (string? url=null, bool focus=true, bool source=false) {
		this.construct_tab (url, focus, source);
	}

	private void construct_tab (string? url, bool focus=true, bool source=false) {
		BrowserTab tab = new BrowserTab(url, source);
		int new_tab_number = this.append_page(tab, tab.label);
		tab.toolbar.connect_menu(this.browser_menu);
		tab.open_in_new_tab.connect((tab, url) => {
			this.new_tab (url, false);
		});
		tab.title_changed.connect((tab, title) => {
			this.on_title_changed(tab, title);
		});
		tab.label.close_button.clicked.connect((button) => {
			this.close_tab(tab);
		});
		tab.web_view.download_requested.connect(this.on_download_requested);
		tab.web_view.document_load_finished.connect_after((web_view, web_frame) => {
			this.save_session (false);
		});
		this.set_tab_reorderable(tab, true);
		this.resize_tabs();
		tab.show_all();
		if (focus) this.set_current_page (new_tab_number);
		if (url == null) tab.toolbar.address_bar.grab_focus();
	}

	public void close_tab(BrowserTab tab) {
		int page_num = this.page_num(tab);
		if (page_num != -1) {
			//this.closed_tabs.push (tab.web_view.uri);
			tab.web_view.destroy();
			tab.toolbar.destroy();
			this.remove_page(page_num);
		}
		if (this.get_n_pages() == 0) {
			Widget window = this.get_toplevel();
			window.destroy();
		}
		this.resize_tabs ();
	}

	public void on_title_changed(BrowserTab tab, string? title) {
		int current_page = this.get_current_page ();
		int page_num = this.page_num(tab);
		if (page_num == current_page) this.title_changed (title);
		this.title_changed (title);
	}

	public void on_tab_changed(Widget widget, uint page_num) {
		BrowserTab tab = (BrowserTab) widget;
		this.active_tab = tab;
		this.title_changed(tab.title);
		if (tab.title == "New Tab") {
			tab.toolbar.address_bar.grab_focus();
		} else {
			tab.web_view.grab_focus();
		}
	}

	public bool on_download_requested(WebView web_view, Object download_obj) {
		Thunderbolt.Download download = new Thunderbolt.Download(download_obj);
		Gtk.Window window = (Gtk.Window) this.get_toplevel ();
		Gtk.Application app = window.get_application ();
		app.add_window(download);
		download.show_all ();
		return true;
	}

}
