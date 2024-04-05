import { getPostFetchOptions } from '$lib'

/** @type {import('./$types').PageLoad} */
export async function load() {
    //TODO fetch data from webserver

    try {
        return await fetch("http://192.168.0.149:8080/get_daily", getPostFetchOptions()) 
            .then(res => res.json())

    } catch(e) {
        console.error(e)
    }

/*
	return {
        weekday: "Saturday",
        exercises: [
            {name:"Push Up", description: "A simple push up", sets: 3, reps: 12, isDone: true},
            {name:"Pull Up", description: "Just some pull ups", sets: 3, reps: 10, isDone: false},
            {name:"Weighted Squat", description: "", sets: 3, reps: 8, isDone: true},
            {name:"Plank", description: "Maybe add minute as param", sets: 0, reps: 0, isDone: false},
        ]
    }
    */

}
