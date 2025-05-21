List<String> listStr = new List<String>{'Mike','Shirley', 'Charlie', 'Eddie', 'Ruthie', 'Becca', 'Tilda'};
System.debug('listStr: '+JSON.serializePretty(listStr));

Set<String> setStr = new Set<String>(listStr);
System.debug('setStr: '+JSON.serializePretty(setStr));

//Map<Integer, String> mapStr = new Map<Integer, String>{listStr}; 
Map<String, String> mapStr = new Map<String, String>(); 
mapStr.putAll(listStr);
System.debug('mapStr: '+JSON.serializePretty(mapStr));

List<String> listStr2 = new List<String>{'Shirley', 'Mike', 'John', 'Llew', 'John', 'Margaret', 'Ruth', 'Ed'};
System.debug('listStr: '+JSON.serializePretty(listStr2));

listStr.addAll(listStr2);
System.debug('listStr2: '+JSON.serializePretty(listStr));

setStr.addAll(listStr2);
System.debug('setStr: '+JSON.serializePretty(setStr));

SOQL.setPrimaryContact();