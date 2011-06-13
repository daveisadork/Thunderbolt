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

public class Thunderbolt.Cache : Object {
	public string BASE_DIRECTORY;
	public string FAVICONS;
	public string DATABASES;
	public string COOKIES;
	public string DOWNLOADS;

	public Cache () {
		BASE_DIRECTORY = @"$(Environment.get_user_cache_dir())/thunderbolt";
		FAVICONS = @"$BASE_DIRECTORY/favicons";
		DATABASES = @"$BASE_DIRECTORY/databases";
		COOKIES = @"$BASE_DIRECTORY/cookies.txt";
		DOWNLOADS = Environment.get_user_special_dir (UserDirectory.DOWNLOAD);
		try {
			File favicons = File.new_for_path (FAVICONS);
			favicons.make_directory_with_parents (null);
		} catch (Error e) {
			//print(@"e.message\n");
		}

	}
}