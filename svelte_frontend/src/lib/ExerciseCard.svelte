<script>
    export const ExerciseCard = this
    export let name = "Exercise Name"
    export let description = "Description.."
    export let isDone = false
</script>

<div 
    id = "exerciseCard" 
    on:click
    class = {isDone ? "done" : "todo"}
>
    {name}
    <br>
    {description}
</div>

<style>
    #exerciseCard {
        border: 1px solid black;
        border-radius: 15px;

        height: 50px;

        padding: 10px;
        margin: 10px;

        text-align: center;

    }

    .todo {
        background-color: #131518;
    }

    .done {
        background-color: #2e7d32;
    }
</style>
