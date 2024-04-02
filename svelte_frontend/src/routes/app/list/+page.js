/** @type {import('./$types').PageLoad} */
export function load() {
    //TODO fetch data from webserver
    /*
    try {
        return await fetch("/get_daily")
    } catch(e) {

    }
    */
	return {
        weekday: "Saturday",
        exercises: [
            {name:"Push Up", description: "A simple push up", sets: 3, reps: 12, isDone: true},
            {name:"Pull Up", description: "Just some pull ups", sets: 3, reps: 10, isDone: false},
            {name:"Weighted Squat", description: "", sets: 3, reps: 8, isDone: true},
            {name:"Plank", description: "Maybe add minute as param", sets: 0, reps: 0, isDone: false},
        ]
    }
}
