const fs = require('fs')

fs.readFile('./dep/raylib-5.0_webassembly/include/raylib.h', 'utf8', create_shim)

// Polyfill from https://gist.github.com/TheBrenny/039add509c87a3143b9c077f76aa550b
if(!String.prototype.matchAll) {
    String.prototype.matchAll = function (rx) {
        if (typeof rx === "string") rx = new RegExp(rx, "g"); // coerce a string to be a global regex
        rx = new RegExp(rx); // Clone the regex so we don't update the last index on the regex they pass us
        let cap = []; // the single capture
        let all = []; // all the captures (return this)
        while ((cap = rx.exec(this)) !== null) all.push(cap); // execute and add
        return all; // profit!
    };
}

function create_shim(err, headerfile) {
   let headlist = headerfile
   let affected_functions = []
   let shim_script = '// Shim generated at ' + Date.now() + ' by reneeverly/raylib-fortran-wasm/patch_prototype.js\n\n#include "raylib.h"\n\n'

   // Regex to detect function definitions:
   // Captures return type, function name, and arguments in full
   const detect_functions = /^(?:\s*)([A-z*0-9\s]+)(?:\s+)([A-z*0-9]+)(?:\s*)\((.*?)\)/gm

   let all_functions = [...headlist.matchAll(detect_functions)]

   function mark_as_affected_and_return_shimnames(i) {
      // eliminate any stray asterisks
      let function_name_no_asterisk = all_functions[i][2].split('*').join('')

      // Add this asterisk-free name to the list of affected functions
      affected_functions.push(function_name_no_asterisk)

      // prepend the function name with `shim_`
      let function_name_shim = all_functions[i][2].replace(function_name_no_asterisk, 'shim_' + function_name_no_asterisk)
      return [function_name_shim, function_name_no_asterisk]
   }

   for (i in all_functions) {
      i = i * 1

      // Check for only void
      if (all_functions[i][3] == 'void') {
         // ES6 get shim and regular name
         let [function_name_shim, function_name_no_asterisk] = mark_as_affected_and_return_shimnames(i)

         // Create the shim
         shim_script += all_functions[i][1] + ' ' + function_name_shim + ' (int i32) {\n   return ' + function_name_no_asterisk + '();\n}\n\n'
      }
      // Check for Vector3 in args (but not *Vector3 or Vector3* or Vector3 thing*)
      else if (all_functions[i][3].includes('Vector3')) {
         // ES6 get shim and regular name
         let [function_name_shim, function_name_no_asterisk] = mark_as_affected_and_return_shimnames(i)

         // start the shim
         shim_script += all_functions[i][1] + ' ' + function_name_shim + ' ('
         let inner_shim = '\n   return ' + function_name_no_asterisk + '('
         
         // Split up the variables
         let params = all_functions[i][3].split(',')
         for (j in params) {
            let argsplit = params[j].split(' ')
            let varname = argsplit[argsplit.length - 1]
            if (params[j].includes('Vector3') && !params[j].includes('*')) {
               shim_script += 'float ' + varname + '_1, float ' + varname + '_2, float ' + varname + '_3,'
               inner_shim += '(Vector3){' + varname + '_1, ' + varname + '_2, ' + varname + '_3},'
            } else {
               shim_script += params[j] + ','
               // fix build error by removing asterisks from inner shim
               inner_shim += varname.split('*').join('') + ','
            }
         }
         // round out parens
         if (shim_script[shim_script.length - 1] == ',') shim_script = shim_script.substring(0, shim_script.length - 1) + ')'
         if (inner_shim[inner_shim.length - 1] == ',') inner_shim = inner_shim.substring(0, inner_shim.length - 1) + ')'

         // combine the outer and inner shim
         shim_script += ' {' + inner_shim + ';\n}\n'
      }
      // And Vector2
      else if (all_functions[i][3].includes('Vector2')) {
         // ES6 get shim and regular name
         let [function_name_shim, function_name_no_asterisk] = mark_as_affected_and_return_shimnames(i)

         // start the shim
         shim_script += all_functions[i][1] + ' ' + function_name_shim + ' ('
         let inner_shim = '\n   return ' + function_name_no_asterisk + '('
         
         // Split up the variables
         let params = all_functions[i][3].split(',')
         for (j in params) {
            let argsplit = params[j].split(' ')
            let varname = argsplit[argsplit.length - 1]
            if (params[j].includes('Vector2') && !params[j].includes('*')) {
               shim_script += 'float ' + varname + '_1, float ' + varname + '_2,'
               inner_shim += '(Vector2){' + varname + '_1, ' + varname + '_2},'
            } else {
               shim_script += params[j] + ','
               // fix build error by removing asterisks from inner shim
               inner_shim += varname.split('*').join('') + ','
            }
         }
         // round out parens
         if (shim_script[shim_script.length - 1] == ',') shim_script = shim_script.substring(0, shim_script.length - 1) + ')'
         if (inner_shim[inner_shim.length - 1] == ',') inner_shim = inner_shim.substring(0, inner_shim.length - 1) + ')'

         // combine the outer and inner shim
         shim_script += ' {' + inner_shim + ';\n}\n'
      }

      
   }

   // output shimscript
   fs.writeFile('./lib/shim_raylib50.c', shim_script, (err) => { if (err) { console.log(err) }})
   fs.writeFile('./lib/shim_raylib50_affect.txt', affected_functions.join('\n'), (err) => { if (err){console.log(err)}})
}
