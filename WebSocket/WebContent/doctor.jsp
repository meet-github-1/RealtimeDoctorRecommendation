<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<title>Doctor Portal</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
<style>
	.btn{
		margin:0 5px;
	}
	.btn:hover{
		box-shadow:3px 3px 8px #888888;
	}
	.hide{
		display:none;
	}
	.show{
		display:inline-block;
	}
</style>
</head>
<body>
	<div class="container table-responsive">
		<label style="margin-top:30px;">Patient Status will be displayed in the table below</label>
		<table id="example" class="table table-striped" style="margin-top:30px;">
			<thead>
				<tr>
					<th>Patient Name</th>
					<th>Oxygen Levels</th>
					<th>Temperature</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody>
				<tr>
				</tr>
			</tbody>
		</table>
	</div>
	<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
	  <div class="modal-dialog" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <h5 class="modal-title" id="exampleModalLabel">Online Prescription</h5>
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
	      </div>
	      <div class="modal-body">
	        <label>Medicine Name</label>
	        <input type="text" class="form-control" id="medicine_name" style="margin:10px 0;" required>
	        <label>Description</label>
	        <textarea id="medicine_description" class="form-control" required></textarea>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
	        <button type="button" class="btn btn-success" id="submit_btn">Submit</button>
	      </div>
	    </div>
	  </div>
	</div>
	<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" ></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
	<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
	
	<script type="text/javascript">
		var websocket=new WebSocket("ws://localhost:8080/WebSocket/VitalCheckEndPoint");
		websocket.onmessage=function processVital(vital){
			var jsonData=JSON.parse(vital.data);
			if(jsonData.message!=null)
				{
					var details=jsonData.message.split(',');
					var row=document.getElementById('example').insertRow();
					row.innerHTML="<td>"+details[0]+"</td><td>"+details[1]+"<td>"+details[2]+"</td><td><button class=\"btn btn-danger btn-sm\" onclick=\"sendInstructions('"+details[0]+"','ambulance','"+details[3]+"')\">Summon Ambulance</button><button type=\"button\" class=\"btn btn-primary btn-sm\" onclick=\"sendInstructions('"+details[0]+"','medication','"+details[2]+"')\">Suggest Medication</button></td>";	
				}
		}
		function sendInstructions(username,message,phone){
			if(message=='medication'){
				$('#exampleModal').modal('show');
				document.getElementById("submit_btn").addEventListener("click",function(){
					var medicine=medicine_name.value;
					var description=medicine_description.value;
					websocket.send(username+","+message+","+medicine+","+description);
					medicine_name.value="";
					medicine_description.value="";
					$('#exampleModal').modal('hide');
				});
			}
			else{
				websocket.send(username+","+message+","+phone);
			}
		}
	</script>
	
</body>
</html>
