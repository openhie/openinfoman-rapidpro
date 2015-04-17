import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";

declare namespace csd = "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;



let $careServicesSubRequest :=  
  <csd:careServicesRequest>
    <csd:function  urn="urn:ihe:iti:csd:2014:stored-function:provider-search" >
      <csd:requestParams/>
    </csd:function>
  </csd:careServicesRequest> 

let $providers := csr_proc:process_CSR_stored_results($csd_webconf:db, /. , $careServicesSubRequest)


let $contacts :=  
  <json type='object'>
    <contacts type="array">
    {
      for $provider in  $providers/csd:providerDirectory/csd:provider
      let $uuid := lower-case(string($provider/@entityID))
      let $name := ($provider/csd:demographic/csd:name/csd:commonName)[1]/text()
      let $tel_1 := $provider/telephone_1/text()
      let $tel_2 := $provider/telephone_2/text()
      let $tel_3 := $provider/telephone_3/text()
      return 
	if (true()) (:  ($uuid and $name)  :)
       then 
         <_  type="object">
	   <name>{$name}</name>
	   <urns type="array">
             { if ($tel_1) then   <_ type='string'>tel:{$tel_1}</_> else ()} 
             { if ($tel_2) then   <_ type='string'>tel:{$tel_2}</_> else ()} 
             { if ($tel_3) then   <_ type='string'>tel:{$tel_3}</_> else ()} 
	   </urns>
	   <fields type="object">
             <Globalid>{$uuid}</Globalid>
	   </fields>
         </_>
       else ()
    }
    </contacts>
  </json>


return json:serialize($contacts,map{"format":"direct"})  
