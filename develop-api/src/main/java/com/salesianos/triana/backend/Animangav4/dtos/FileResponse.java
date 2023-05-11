package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FileResponse {

    private String name;
    private String uri;
    private String type;
    private long size;

}
