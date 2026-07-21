<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Blue Team Security+ Lab</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
body {
    font-family: Arial, sans-serif;
    background: #07182e;
    color: #e8f1ff;
    margin: 0;
}

header {
    background: #0b4f9c;
    padding: 20px;
    text-align: center;
}

nav {
    background: #051020;
    padding: 10px;
    text-align: center;
}

button {
    background: #1e90ff;
    border: none;
    color: white;
    padding: 10px 15px;
    margin: 5px;
    cursor: pointer;
    border-radius: 5px;
}

button:hover {
    background: #63b3ff;
}

.container {
    padding: 25px;
}

.card {
    background: #102a43;
    padding: 20px;
    margin: 15px 0;
    border-left: 5px solid #1e90ff;
    border-radius: 8px;
}

.completed {
    border-left-color: #00ff88;
}

.token {
    background: black;
    padding: 10px;
    color: #00ff88;
    font-family: monospace;
}

.hidden {
    display: none;
}

.progress {
    background: #23395d;
    height: 25px;
    border-radius: 20px;
    overflow: hidden;
}

.progress-bar {
    background: #00ff88;
    height: 100%;
    width: 0%;
    text-align: center;
    color: black;
}

.certificate {
    display: none;
}

@media print {
    body * {
        display: none;
    }

    .certificate {
        display: block;
        color: black;
        padding: 50px;
        text-align: center;
    }
}
</style>

</head>

<body>

<header>
<h1>Blue Team Security+ Lab</h1>
<p>Defensive Security Training Environment</p>
</header>


<nav>
<button onclick="showPage('home')">Dashboard</button>
<button onclick="showPage('directory')">Challenge Directory</button>
<button onclick="printCertificate()">Print Certificate</button>
</nav>


<div class="container">

<section id="home">

<h2>Mission Dashboard</h2>

<p>
Completed Challenges:
<span id="count">0</span>/3
</p>

<div class="progress">
<div class="progress-bar" id="progress"></div>
</div>

<h3>Available Challenges</h3>

<div id="challengeList"></div>

</section>



<section id="directory" class="hidden">

<h2>Challenge Directory</h2>

<div class="card">
<h3>Challenge 1: Log Analysis</h3>
<p>
Review authentication logs and identify suspicious login activity.
</p>

<p>
Objective:
Find the hidden token inside the event record.
</p>

<input id="token1" placeholder="Enter token">

<button onclick="submitToken(1)">
Submit
</button>

</div>



<div class="card">

<h3>Challenge 2: Phishing Investigation</h3>

<p>
Analyze an email header and identify indicators of compromise.
</p>

<p>
Objective:
Recover the phishing investigation token.
</p>

<input id="token2" placeholder="Enter token">

<button onclick="submitToken(2)">
Submit
</button>

</div>



<div class="card">

<h3>Challenge 3: Incident Response</h3>

<p>
Perform basic containment steps after detecting malware activity.
</p>

<p>
Objective:
Submit the incident response completion token.
</p>

<input id="token3" placeholder="Enter token">

<button onclick="submitToken(3)">
Submit
</button>

</div>

</section>

</div>



<div class="certificate">

<h1>Certificate of Completion</h1>

<h2>Blue Team Security+ Lab</h2>

<p>This certifies that</p>

<h2 id="certName">Security Analyst</h2>

<p>
has successfully completed all defensive security challenges.
</p>

<p>
Completion Date:
<span id="date"></span>
</p>

</div>



<script>

const challenges = [
{
id:1,
name:"Log Analysis",
token:"LOG-SEC-001"
},
{
id:2,
name:"Phishing Investigation",
token:"MAIL-SEC-002"
},
{
id:3,
name:"Incident Response",
token:"IR-SEC-003"
}
];


let completed =
JSON.parse(localStorage.getItem("completed")) || [];



function showPage(page){

document.getElementById("home")
.classList.add("hidden");

document.getElementById("directory")
.classList.add("hidden");

document.getElementById(page)
.classList.remove("hidden");

}



function submitToken(id){

let challenge =
challenges.find(c=>c.id===id);

let input =
document.getElementById("token"+id).value;


if(input === challenge.token){

if(!completed.includes(id)){
completed.push(id);
}

localStorage.setItem(
"completed",
JSON.stringify(completed)
);

alert("Challenge completed!");

updateDashboard();

}

else {

alert("Invalid token");

}

}



function updateDashboard(){

let count =
document.getElementById("count");

count.innerHTML =
completed.length;


let percent =
(completed.length / challenges.length)*100;


document.getElementById("progress")
.style.width =
percent+"%";


let list =
document.getElementById("challengeList");

list.innerHTML="";


challenges.forEach(c=>{

let done =
completed.includes(c.id);

list.innerHTML += `

<div class="card ${done?'completed':''}">

<h3>${c.name}</h3>

<p>
Status:
${done?"Completed":"Available"}
</p>

</div>

`;

});

}



function printCertificate(){

if(completed.length !== challenges.length){

alert(
"Complete all challenges before printing your certificate."
);

return;

}


document.getElementById("date")
.innerHTML =
new Date().toLocaleDateString();


window.print();

}



updateDashboard();

</script>


</body>
</html>
