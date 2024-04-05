<script>
    import ExerciseCard from "$lib/ExerciseCard.svelte"
    /** @type {import('./$types').PageData} */
    import { goto } from '$app/navigation';
    
	export let data;

</script>

<div id="container">
    <h2>Today is {data.weekday}</h2>
    <div id = "exerciseList" >
        {#each data.exercises as row}
            <ExerciseCard 
                name = {row.name}
                isDone = {row.is_done}
                description = {row.description}
                on:click = {() => { goto("/app/detail", {state: row}) } }
            />
        {/each}
    </div>
</div>

<style>
    #container {
            height: calc(100% - 15px);
            display: flex;
            flex-flow: column;
        }
    h2, #exerciseList {
        text-align: center;
    }
    h2 {
            flex: 0 1;
        }
    #exerciseList {
            overflow: scroll;
            flex: 1 1;
        }
</style>


