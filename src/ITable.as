package 
{
	import flash.geom.Point;
	import model.TableData;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public interface ITable 
	{
		function addCardTo(card:Poker, con:int=0):void;
		function reset():void;
		function update():void;
		function setTableData(tableData:TableData, isMain:Boolean):void;
		function get id():int;
		function addChip(chip:Chip):void;
		function getChipReferPoint():Point;
	}
	
}