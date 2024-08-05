let ship;
let app;
let displayUpdatePath;
let channelMessageId = 0;
let eventSource;
const channelId = `${Date.now()}${Math.floor(Math.random() * 100)}`;
const channelPath = `${window.location.origin}/~/channel/${channelId}`;
addEventListener('DOMContentLoaded', async () => {
    ship = document.documentElement.getAttribute('ship');
    app = document.documentElement.getAttribute('app');
    displayUpdatePath = document.documentElement.getAttribute('path');
    await connectToShip();
    let eventElements = document.querySelectorAll('[event]');
    eventElements.forEach(el => setEventListeners(el));
});
function setEventListeners(el) {
    const eventTags = el.getAttribute('event');
    const returnTags = el.getAttribute('return');
    eventTags.split(/\s+/).forEach(eventStr => {
        const eventType = eventStr.split('/', 2)[1];
        el[`on${eventType}`] = (e) => pokeShip(e, eventStr, returnTags);
    });
};
async function connectToShip() {
    try {
        const storageKey = `${ship}${app}${displayUpdatePath}`;
        let storedId = localStorage.getItem(storageKey);
        localStorage.setItem(storageKey, channelId);
        if (storedId) {
            const delPath = `${window.location.origin}/~/channel/${storedId}`;
            await fetch(delPath, {
                method: 'PUT',
                body: JSON.stringify([{
                    id: channelMessageId,
                    action: 'delete'
                }])
            });
        };
        const body = JSON.stringify(makeSubscribeBody());
        await fetch(channelPath, { 
            method: 'PUT',
            body
        });
        eventSource = new EventSource(channelPath);
        eventSource.addEventListener('message', handleChannelStream);
    } catch (error) {
        console.error(error);
    };
};
function pokeShip(event, tagString, dataString) {
    try {
        let data = {};
        if (dataString) {
            const dataToReturn = dataString.split(/\s+/);
            dataToReturn.forEach(dataTag => {
                let splitDataTag = dataTag.split('/');
                if (splitDataTag[0] === '') splitDataTag.shift();
                const kind = splitDataTag[0];
                const key = splitDataTag.pop();
                if (kind === 'event') {
                    if (!(key in event)) {
                        console.error(`Property: ${key} does not exist on the event object`);
                        return;
                    };
                    data[dataTag] = String(event[key]);
                } else if (kind === 'target') {
                    if (!(key in event.currentTarget)) {
                        console.error(`Property: ${key} does not exist on the target object`);
                        return;
                    };
                    data[dataTag] = String(event.currentTarget[key]);
                } else {
                    const elementId = splitDataTag.join('/');
                    const linkedEl = document.getElementById(elementId);
                    if (!linkedEl) {
                        console.error(`No element found for id: ${kind}`);
                        return;
                    };
                    if (!(key in linkedEl)) {
                        console.error(`Property: ${key} does not exist on the object with id: ${elementId}`);
                        return;
                    };
                    data[dataTag] = String(linkedEl[key]);
                };
            });
        };
        fetch(channelPath, {
            method: 'PUT',
            body: JSON.stringify(makePokeBody({
                tags: tagString,
                data
            }))
        });
    } catch (error) {
        console.error(error);
    };
};
function handleChannelStream(event) {
    try {
        const streamResponse = JSON.parse(event.data);
        fetch(channelPath, {
            method: 'PUT',
            body: JSON.stringify(makeAck(streamResponse.id))
        });
        if (streamResponse.response !== 'diff') return;
        const gust = streamResponse.json;
        if (!gust) return;
        console.log(gust);
        gust.forEach(gustObj => {
            switch (gustObj.p) {
                case 'd':
                    gustObj.q.forEach(key => {
                        document.querySelector(`[key="${key}"]`).remove();
                    });
                    break;
                case 'n':
                    let parent = document.querySelector(`[key="${gustObj.q}"]`);
                    if (gustObj.r === 0) {
                        parent.insertAdjacentHTML('afterbegin', gustObj.s);
                    } else if (gustObj.r === parent.childNodes.length) {
                        parent.insertAdjacentHTML('beforeend', gustObj.s);
                    } else {
                        let indexTarget = parent.childNodes[gustObj.r];
                        if (indexTarget.nodeType === 1) {
                            indexTarget.insertAdjacentHTML('beforebegin', gustObj.s);
                        } else {
                            let placeholder = document.createElement('div');
                            parent.insertBefore(placeholder, indexTarget);
                            placeholder = parent.childNodes[gustObj.r];
                            placeholder.outerHTML = gustObj.s;
                        };
                    };
                    let newNode = parent.childNodes[gustObj.r];
                    if (newNode.getAttribute('event')) {
                        setEventListeners(newNode);
                    };
                    if (newNode.childElementCount > 0) {
                        let needingListeners = newNode.querySelectorAll('[event]');
                        needingListeners.forEach(child => setEventListeners(child));
                    };
                    break;
                case 'm':
                    let fromNode = document.querySelector(`[key="${gustObj.q}"]`);
                    const fromIndex = [ ...fromNode.parentNode.childNodes ].indexOf(fromNode);
                    if (fromIndex < gustObj.r) gustObj.r++;
                    let toNode = fromNode.parentNode.childNodes[gustObj.r];
                    fromNode.parentNode.insertBefore(fromNode, toNode);
                    break;
                case 'c':
                    let targetNode = document.querySelector(`[key="${gustObj.q}"]`);
                    if (gustObj.r.length) {
                        gustObj.r.forEach(attr => {
                            if (attr === 'event') {
                                let eventVal = targetNode.getAttribute('event').split('/');
                                if (eventVal[0] === '') eventVal.shift();
                                const eventType = eventVal[0];
                                targetNode[`on${eventType}`] = null;
                            };
                            targetNode.removeAttribute(attr);
                        });
                    };
                    if (gustObj.s.length) {
                        gustObj.s.forEach(attr => {
                            const name = attr[0];
                            const value = attr[1];
                            targetNode.setAttribute(name, value);
                            if (name === 'event') setEventListeners(targetNode);
                        });
                    };
                    break;
                case 't':
                    let textWrapperNode = document.querySelector(`[key="${gustObj.q}"]`);
                    textWrapperNode.textContent = gustObj.r;
                    break;
            };
        });
    } catch (error) {
        console.error(error);
    };
};
function makeSubscribeBody() {
    channelMessageId++;
    return [{
        id: channelMessageId,
        action: 'subscribe',
        ship: ship,
        app: app,
        path: displayUpdatePath
    }];
};
function makePokeBody(jsonData) {
    channelMessageId++;
    return [{
        id: channelMessageId,
        action: 'poke',
        ship: ship,
        app: app,
        mark: 'json',
        json: jsonData
    }];
};
function makeAck(eventId) {
    channelMessageId++;
    return [{
        id: channelMessageId,
        action: 'ack',
        "event-id": eventId
    }];
};
