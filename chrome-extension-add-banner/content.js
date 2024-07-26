const operatingMode = "local";
// Array of text and emoji messages
const messages = [
    "So cute! 😊",
    "Wow.... that is 🔥",
    "Party time! 🎉",
    "Keep that going! 📢",
    "Thank you .. Thank you .. Thank you! 🙏"
];
const apiURL = 'https://*.*.us-east-1.amazonaws.com/default/messageAPI';
const banner = document.createElement('div');
banner.id = 'custom-banner';
banner.innerText = messages[0];
document.body.append(banner);
console.log('Banner Added.');

function setBannerText(text) {
    banner.innerText = text;
}

let counter = 1;
let serverNextIndex = 0;
setInterval(async () => {
    let newIndex = counter % messages.length;
    let newMessage = '';
    let useLocalMessage = true;
    if (operatingMode === "local") {
        //Do not fetch data from server
    } else {
        try {
            const myHeaders = new Headers();
            myHeaders.append("Content-Type", "application/json");
            myHeaders.append("Accept", "application/json");

            const response = await fetch(apiURL + '?index=' + serverNextIndex, {
                method: 'GET',
                headers: myHeaders
            });
            
            if (response.ok) {
                let data = await response.json();
                serverNextIndex = data.nextIndex;
                for (let i = 0; i < data.messages.length; i++) {
                    newMessage += data.messages[i].name + " : " + data.messages[i].text + "\n";
                }
                useLocalMessage = false;
            } else {
                throw new Error('Network response was not ok');
            }
        } catch (error) {
            console.log(error);
            // Use standard messages
        }
    }
    if (useLocalMessage == true) {
        for (let i = 0; i < messages.length; i++) {
            newMessage += messages[newIndex % messages.length] + '\n';
            newIndex++;
        }
    }
    setBannerText(newMessage);
    counter++;
}, 10000); // Add a new banner every 3 seconds