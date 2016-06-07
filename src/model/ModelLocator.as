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
package model
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class ModelLocator
	{
		private static var instance:ModelLocator = new ModelLocator();
		/**
		 * can be used anytime the resourcemanager is needed
		 */
		public static var resourceManagerInstance:IResourceManager;
		
		public function ModelLocator()
		{
			if (instance != null) {
				throw new Error("ModelLocator class can only be instantiated through ModelLocator.getInstance()");	
			}
			resourceManagerInstance = ResourceManager.getInstance();
		}
		
		public static function getInstance():ModelLocator {
			if (instance == null) instance = new ModelLocator();
			return instance;
		}
		

	}
}