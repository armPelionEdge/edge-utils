/*
 * Copyright (c) 2018, Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


var execSync = require('child_process').execSync;
function createVirtualDevices() {
    console.log('Creating virtual devices...');
    return new Promise(function(resolve, reject) {
        dev$.selectByID('VirtualDeviceDriver').call('listTemplates').then(function(resp) {
            if(resp && resp.VirtualDeviceDriver && resp.VirtualDeviceDriver.response && resp.VirtualDeviceDriver.response.result) {
                let templates = resp.VirtualDeviceDriver.response.result;
                let p = [];
                templates.forEach(function(tempType) {
                    console.log('Creating virtual device of type ' + tempType);
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                    p.push(dev$.selectByID('VirtualDeviceDriver').call('create', tempType));
                });
                Promise.all(p).then(function() {
                    console.log("Successfully created lot of virtual devices. Rebooting in 5 seconds...");
                    setTimeout(function() {
                        execSync('reboot');
                    }, 5000);
                    resolve();
                }, function(err) {
                    return reject(err);
                });
            } else {
                return reject('Failed to list virtual device template list');
            }
        }, function(err) {
            console.error('Failed to create virtual devices ' + err);
            return reject(err);
        });
    });
}

createVirtualDevices();