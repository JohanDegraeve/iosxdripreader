/**
 Copyright (C) 2016  Johan Degraeve
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/gpl.txt>.
 
 */
package databaseclasses
{
	import Utilities.UniqueId;

	/**
	 * class that holds and does generic attributes and methods for all classes that will do google sync etc. 
	 */
	public class SuperDatabaseClass
	{
		public var lastModifiedTimestamp:Number;
		public var _uniqueId:String;
		public function SuperDatabaseClass()
		{
			lastModifiedTimestamp = (new Date()).valueOf();
			_uniqueId = Utilities.UniqueId.createEventId();
		}
	}
}