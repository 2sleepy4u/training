<script>
    import ExerciseCard from "$lib/ExerciseCard.svelte"
    /** @type {import('./$types').PageData} */
    import { goto } from '$app/navigation';
    
	export let data;

</script>

<div id = "exerciseList" >
    <h2>Today is {data.weekday}</h2>
    {#each data.exercises as row}
        <ExerciseCard 
            name = {row.name}
            isDone = {row.isDone}
            description = {row.description}
            on:click = {() => { goto("/app/detail", {state: row}) } }
        />
    {/each}
</div>

<style>
    #exerciseList {
        text-align: center;
    }
</style>


