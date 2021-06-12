package com.websocket;
import java.io.StringWriter;
import java.util.*;
import javax.websocket.server.*;
import javax.websocket.*;
import javax.json.*;

@ServerEndpoint(value="/VitalCheckEndPoint",configurator = VitalCheckconfigurator.class)
public class VitalCheckEndPoint {
	
	static Set<Session>subscriber=Collections.synchronizedSet(new HashSet<Session>());
	
	@OnOpen
	public void handleOpen(Session userSession,EndpointConfig econfig) {
		userSession.getUserProperties().put("username",econfig.getUserProperties().get("username"));
		subscriber.add(userSession);
	}
	
	@OnMessage
	public void handleMessage(Session userSession,String message) {
		String username=(String)userSession.getUserProperties().get("username");
		
		if(username!=null && !username.equals("doctor")) {
			subscriber.stream().forEach(x->{
				try {
					String strs[]=message.split(",");
					if(x.getUserProperties().get("username").equals("doctor")) {
						//if(Integer.parseInt(strs[0])<90)
						x.getBasicRemote().sendText(buildJSON(username,strs[0]+","+strs[1]+","+strs[2]));
					}
				} catch (Exception e) {
					System.out.println(e.getStackTrace());
				}
			});
		}
		
		else if(username!=null && username.equals("doctor")) {
			String msg[]=message.split(",");
			String patient=msg[0];
			String subject=msg[1];
			
			subscriber.stream().forEach(x->{
				try {
					if(subject.equals("ambulance")) {
						if(x.getUserProperties().get("username").equals(patient)) {
							x.getBasicRemote().sendText(buildJSON("doctor","has summoned an ambulance"));
						}
						else if(x.getUserProperties().get("username").equals("ambulance")) {
							x.getBasicRemote().sendText(buildJSON(patient,msg[2]+","+"requires an ambulance"));
						}
					}
					else if(subject.equals("medication")) {
						if(x.getUserProperties().get("username").equals(patient)) {
							x.getBasicRemote().sendText(buildJSON("doctor",msg[2]+","+msg[3]));
						}
					}
				} catch (Exception e2) {
					System.out.println(e2.getStackTrace());
				}
			});
		}
	}
	
	@OnClose
	public void handleClose(Session userSession) {
		subscriber.remove(userSession);
	}
	
	@OnError
	public void handleError(Throwable t) {
		
	}
	
	private String buildJSON(String username,String message)
	{
	   JsonObject jsonObject=Json.createObjectBuilder().add("message",username+","+message).build();
	   StringWriter stringWriter=new StringWriter();
	   try(JsonWriter jsonWriter=Json.createWriter(stringWriter))
	     {
	         jsonWriter.write(jsonObject);
	     }
	   return stringWriter.toString();
	 }
	
}