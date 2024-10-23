/* Copyright Cartesi and individual authors (see AUTHORS)
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include "libcmt/rollup.h"

static int finish_request(cmt_rollup_t *me, cmt_rollup_finish_t *finish) {
    finish->accept_previous_request = true;
    return cmt_rollup_finish(me, finish);
}

static int handle_advance_state_request(cmt_rollup_t *me, uint64_t *index) {
    cmt_rollup_advance_t advance;
    int rc = cmt_rollup_read_advance_state(me, &advance);
    if (rc)
        return rc;
    *index = advance.index;
    fprintf(stderr, "handling advance with index %d\n", (int) advance.index);
    return 0;
}

static int handle_inspect_state_request(cmt_rollup_t *me) {
    cmt_rollup_inspect_t inspect;
    int rc = cmt_rollup_read_inspect_state(me, &inspect);
    if (rc)
        return rc;
    fprintf(stderr, "handling inspect\n");
    return 0;
}

static int handle_request(cmt_rollup_t *me, cmt_rollup_finish_t *finish, uint64_t *index) {
    switch (finish->next_request_type) {
        case HTIF_YIELD_REASON_ADVANCE:
            return handle_advance_state_request(me, index);
        case HTIF_YIELD_REASON_INSPECT:
            return handle_inspect_state_request(me);
        default:
            /* unknown request type */
            fprintf(stderr, "Unknown request type %d\n", finish->next_request_type);
            return -1;
    }
    return 0;
}

int main() {
    cmt_rollup_t rollup;
    uint64_t advance_index = 0;

    if (cmt_rollup_init(&rollup) != 0)
        return EXIT_FAILURE;

    /* Accept the initial request */
    cmt_rollup_finish_t finish;
    if (finish_request(&rollup, &finish) != 0) {
        exit(1);
    }

    /* handle a request, then wait for next */
    for (;;) {
        if (handle_request(&rollup, &finish, &advance_index) != 0) {
            break;
        }
        if (finish_request(&rollup, &finish) != 0) {
            break;
        }
    }

    cmt_rollup_fini(&rollup);
    fprintf(stderr, "Exiting...\n");
    return 1;
}
