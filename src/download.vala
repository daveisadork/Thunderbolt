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
using WebKit;
using Soup;

class Thunderbolt.Download : Window {

	WebKit.Download download;
	LinkButton remote_uri;
	VBox vbox;
	Grid grid;
	HButtonBox button_box;
	ProgressBar progress;
	Button cancel_button;
	Button open_folder_button;
	Button open_button;
	Cache cache;
	Label est_label;
	Label time_label;
	Label rate_label;
	Label transfer_rate;
	string filename;
	string? dest_uri;
	string? temp_uri;
	File dest_file;
	File temp_file;

	public Download(Object download_obj) {
		cache = new Cache();
		this.set_data("window-type", "download");
		download = (WebKit.Download) download_obj;
		filename = download.get_suggested_filename();
		URI uri = new URI(download.get_uri());
		this.set_border_width (5);
		this.set_title(@"Downloading $filename");
		vbox = new VBox(true, 2);
		vbox.set_border_width (5);
		vbox.set_homogeneous (false);
		remote_uri = new LinkButton.with_label(uri.to_string(false),
		                                       @"$filename from $(uri.host)");
		progress = new ProgressBar();
		progress.set_show_text (true);
		button_box = new HButtonBox();
		button_box.set_layout(ButtonBoxStyle.END);
		button_box.set_spacing (6);
		button_box.set_border_width (5);
		cancel_button = new Button.from_stock (Stock.CANCEL);
		cancel_button.clicked.connect(this.on_cancel_button_clicked);
		open_button = new Button.from_stock(Stock.OPEN);
		open_button.set_no_show_all(true);
		open_button.clicked.connect(this.on_open_button_clicked);
		
		open_folder_button = new Button.from_stock(Stock.OPEN);
		open_folder_button.clicked.connect(this.on_open_folder_button_clicked);
		open_folder_button.set_label ("Open Folder");
		
		button_box.pack_start (open_folder_button, false, false, 0);
		button_box.pack_start (cancel_button, false, false, 0);
		button_box.pack_start (open_button, false, false, 0);
		vbox.pack_start(remote_uri, false, true, 0);
		vbox.pack_start(progress, false, true, 5);
		
		grid = new Grid();
		est_label = new Label("Estimated Time Left:");
		est_label.set_alignment (0.0f, 0.5f);
		est_label.set_margin_right (5);
		time_label = new Label("");
		time_label.set_alignment (0.0f, 0.5f);
		rate_label = new Label("Transfer Rate:");
		rate_label.set_margin_right (5);
		rate_label.set_alignment (0.0f, 0.5f);
		transfer_rate = new Label("");
		transfer_rate.set_alignment (0.0f, 0.5f);
		grid.attach(est_label, 0, 0, 1, 1);
		grid.attach(time_label, 1, 0, 1, 1);
		grid.attach(rate_label, 0, 1, 1, 1);
		grid.attach(transfer_rate, 1, 1, 1, 1);
		vbox.pack_start(grid, false, false, 0);
		vbox.pack_start(button_box, true, false, 0);
		this.add(vbox);
		this.set_position(WindowPosition.CENTER);
		this.show.connect(this.on_show);
	}

	public void on_show() {
		FileChooserDialog chooser_dialog;
		chooser_dialog = new FileChooserDialog("Download File", this,
		                                       FileChooserAction.SAVE,
		                                       Stock.CANCEL, ResponseType.CANCEL,
		                                       Stock.SAVE, ResponseType.ACCEPT,
		                                       null);
		chooser_dialog.set_current_folder(@"$(this.cache.DOWNLOADS)/$(this.filename)");
		chooser_dialog.set_current_name (this.filename);
		chooser_dialog.response.connect(this.on_chooser_response);
		chooser_dialog.set_do_overwrite_confirmation(true);
		chooser_dialog.set_position(WindowPosition.CENTER);
		chooser_dialog.present();
	}

	public void on_chooser_response(Dialog dialog, int response) {
		FileChooserDialog chooser_dialog = (FileChooserDialog) dialog;
		if (response == ResponseType.ACCEPT) {
			this.dest_uri = chooser_dialog.get_uri();
			this.temp_uri = @"$(this.dest_uri).part";
			this.dest_file = File.new_for_uri (this.dest_uri);
			try {
				this.dest_file.create (FileCreateFlags.NONE, null);
			} catch (Error e) {
				//print(@"$e\n");
			}
			this.temp_file = File.new_for_uri (this.temp_uri);
			try {
				this.temp_file.delete(null);
			} catch (Error e) {
				//print(@"$e\n");
			}
			this.filename = this.dest_file.get_basename ();
			this.download.set_destination_uri(this.temp_uri);
			chooser_dialog.destroy();
			this.download.notify["progress"].connect(this.on_progress_notify);
			this.download.notify["status"].connect(this.on_status_notify);
			this.download.start();
		} else {
			chooser_dialog.destroy();
			this.dest_uri = null;
			this.temp_uri = null;
			this.download.cancel();
			this.destroy();
		}
	}

	public void on_status_notify() {
		switch (this.download.status) {
			case DownloadStatus.ERROR:
				if (this.dest_uri != null) {
					try {
						this.dest_file.delete(null);
					} catch (Error e) {
						//print(@"$(e.message)\n");
					}
					try {
						this.temp_file.delete(null);
					} catch (Error e) {
						//print(@"$(e.message)\n");
					}
				}
				this.destroy();
				break;
			case DownloadStatus.CREATED:
				break;
			case DownloadStatus.STARTED:
				break;
			case DownloadStatus.CANCELLED:
				if (this.dest_uri != null) {
					try {
						this.dest_file.delete(null);
					} catch (Error e) {
						//print(@"$(e.message)\n");
					}
					try {
						this.temp_file.delete(null);
					} catch (Error e) {
						//print(@"$(e.message)\n");
					}
				}
				this.destroy();
				break;
			case DownloadStatus.FINISHED:
				try {
					this.temp_file.move(this.dest_file,
						                FileCopyFlags.OVERWRITE,
						                null, null);
				} catch (Error e) {
					//print(@"$(e.message)\n");
				}
				this.cancel_button.hide();
				this.open_button.show();
				break;
		}
	}

	public void on_progress_notify() {
		uint64 current_size = this.download.current_size;
		uint64 total_size = this.download.total_size;
		double et = this.download.get_elapsed_time();
		double rate = current_size / et;
		double total_time = et / this.download.progress;
		int64 time_remain = Utils.round(total_time - et);
		DateTime date_time_remain = new DateTime.from_unix_utc (time_remain);
		string time_format = date_time_remain.format ("%H:%M:%S");
		string tot_size_units = "B";
		if (total_size > 1024 * 1024 * 1024) {
			total_size = total_size / 1024 / 1024 / 1024;
			tot_size_units = "GiB";
		} else if (total_size > 1024 * 1024) {
			total_size = total_size / 1024 / 1024;
			tot_size_units = "MiB";
		} else if (total_size >= 1024) {
			total_size = total_size / 1024;
			tot_size_units = "KiB";
		}
		string cur_size_units = "B";
		if (current_size > 1024 * 1024 * 1024) {
			current_size = current_size / 1024 / 1024 / 1024;
			cur_size_units = "GiB";
		}else if (current_size > 1024 * 1024) {
			current_size = current_size / 1024 / 1024;
			cur_size_units = "MiB";
		} else if (current_size >= 1024) {
			current_size = current_size / 1024;
			cur_size_units = "KiB";
		}
		string rate_units = "B/sec";
		if (rate > 1024 * 1024 * 1024) {
			rate = rate / 1024 / 1024 / 1024;
			rate_units = "GiB/sec";
		} else if (rate > 1024 * 1024) {
			rate = rate / 1024 / 1024;
			rate_units = "MiB/sec";
		} else if (rate >= 1024) {
			rate = rate / 1024;
			rate_units = "KiB/sec";
		}
		int rate_int = Utils.round(rate);
		this.time_label.set_text (@"$time_format ($current_size$cur_size_units of $total_size$tot_size_units)");
		this.transfer_rate.set_text(@"$rate_int $rate_units");
		this.progress.set_fraction(this.download.progress);
		string title = @"$(Utils.round(this.progress.get_fraction () * 100))% Downloading $(this.filename)";
		this.set_title(title);
	}

	public void on_open_button_clicked () {
		try {
			show_uri (null, this.dest_file.get_uri(), Gdk.CURRENT_TIME);
		} catch (Error e) {
			//print(@"$e\n");
		}
	}
	
	public void on_open_folder_button_clicked () {
		File parent = this.dest_file.get_parent ();
		try {
			show_uri (null, parent.get_uri(), Gdk.CURRENT_TIME);
		} catch (Error e) {
			//print(@"$e\n");
		}
	}

	public void on_cancel_button_clicked () {
		this.download.cancel();
	}
}